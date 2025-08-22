#!/usr/bin/env python3
"""ARB Restructure Tool

Scans Dart sources for localization usages (AppLocalizations.of(context).key, l10n.key,
localizations.key) and proposes/creates new ARB keys grouped by file path.

Approach (conservative, safe):
- New keys are flat snake_case, built from the dart file path under `lib/` plus the
  original key, joined by underscores. E.g. `lib/screens/settings/about_screen.dart`
  + key `header` -> `screens_settings_about_screen_header`.
- This avoids changing ARB JSON structure (keeps flat keys) but groups keys by file.
- The script can run in dry-run mode (default) to show planned changes, or with
  --apply to actually modify ARB and Dart files. Backups are created when applying.

Usage:
  python tools/arb_restructure.py        # dry-run
  python tools/arb_restructure.py --apply --backup

Notes/assumptions:
- We assume localization property access is simple property access like `l10n.header`
  or `AppLocalizations.of(context)!.header` (no dynamic string lookup).
- If a key is used in multiple files, the first encountered occurrence determines
  the file-based prefix.
"""

import argparse
import json
import os
import re
import shutil
from collections import defaultdict


LOCALES_DIR = os.path.join("lib", "l10n")
SOURCE_DIR = "lib"


def find_dart_files():
    for root, dirs, files in os.walk(SOURCE_DIR):
        for f in files:
            if f.endswith(".dart"):
                yield os.path.join(root, f)


def extract_keys_from_file(path):
    """Return set of localization keys referenced in this dart file."""
    text = open(path, encoding="utf-8").read()
    # match patterns like AppLocalizations.of(context).key or l10n.key or localizations.key
    pattern = re.compile(r"(AppLocalizations\.of\([^\)]*\)|\bl10n\b|\blocalizations\b)\s*(!)?\s*\.\s*([A-Za-z0-9_]+)")
    keys = set(m.group(3) for m in pattern.finditer(text))
    return keys


def path_to_prefix(dart_path):
    # compute relative path under lib/ without extension, replace separators with '_'
    rel = os.path.relpath(dart_path, SOURCE_DIR)
    if rel.startswith(".."):
        rel = os.path.basename(dart_path)
    rel_no_ext = os.path.splitext(rel)[0]
    parts = rel_no_ext.split(os.sep)
    # normalize parts: remove file extensions, keep names
    safe = [p.replace('-', '_') for p in parts]
    return "_".join(safe)


def snake_to_camel(s):
    parts = s.split('_')
    if not parts:
        return s
    return parts[0] + ''.join(p.capitalize() for p in parts[1:])


def to_pascal(s: str) -> str:
    # convert snake or kebab or camel to PascalCase
    s = s.replace('-', '_')
    parts = [p for p in re.split(r'[_\s]+', s) if p]
    return ''.join(p[:1].upper() + p[1:] if p else '' for p in parts)


def make_flat_from_segments(path_segments):
    """Join PascalCase path segments into a flat camelCase key and sanitize it."""
    flat = ''.join(path_segments)
    if flat:
        flat = flat[0].lower() + flat[1:]
    flat = re.sub(r'[^0-9A-Za-z]', '', flat)
    return flat


def choose_output_key(path_segments, old_key):
    """Return the output key to use.

    If the existing `old_key` already contains the folder-structure prefix
    (i.e. the joined path_segments except the final segment), keep `old_key`.
    Otherwise return the computed flat key.
    """
    flat = make_flat_from_segments(path_segments)
    # determine prefix (folder structure) from all but the last path segment
    if len(path_segments) > 1:
        prefix_segments = path_segments[:-1]
        prefix = make_flat_from_segments(prefix_segments)
        if prefix and old_key.lower().startswith(prefix.lower()):
            return old_key
    # fallback: if old_key already equals the flat form, keep it
    if old_key == flat:
        return old_key
    return flat


def set_nested(d: dict, path: list, key: str, value):
    """Set nested dictionary at path (list of segments), final key under that path."""
    cur = d
    for seg in path:
        if seg not in cur or not isinstance(cur[seg], dict):
            cur[seg] = {}
        cur = cur[seg]
    cur[key] = value


def load_arb_files():
    arb_files = []
    if not os.path.isdir(LOCALES_DIR):
        raise SystemExit(f"Locales directory not found: {LOCALES_DIR}")
    for fname in os.listdir(LOCALES_DIR):
        if fname.endswith('.arb'):
            arb_files.append(os.path.join(LOCALES_DIR, fname))
    arb_data = {}
    for p in sorted(arb_files):
        # handle possible BOMs
        with open(p, encoding='utf-8-sig') as fh:
            try:
                arb_data[p] = json.load(fh)
            except Exception as e:
                print(f"Failed to parse {p}: {e}")
                arb_data[p] = {}
    return arb_data


def plan_rewrites():
    # map old_key -> first file path where used
    key_to_file = {}
    file_to_keys = defaultdict(set)
    for dart in find_dart_files():
        keys = extract_keys_from_file(dart)
        if not keys:
            continue
        for k in sorted(keys):
            file_to_keys[dart].add(k)
            if k not in key_to_file:
                key_to_file[k] = dart

    # build mapping old_key -> new_key
    mapping = {}
    for old_key, dart in key_to_file.items():
        # build dotted path segments from dart path: split under lib/, skip 'lib'
        rel = os.path.relpath(dart, SOURCE_DIR)
        rel_no_ext = os.path.splitext(rel)[0]
        parts = rel_no_ext.split(os.sep)
        # remove common suffixes like '_screen' or 'screen' from filenames
        cleaned_parts = []
        for p in parts:
            p_clean = re.sub(r'_?screen$', '', p, flags=re.IGNORECASE)
            cleaned_parts.append(p_clean)
        # build dotted path with PascalCase segments for nested ARB keys
        dotted_parts = [to_pascal(p) for p in cleaned_parts if p]
        # Prepend a top-level 'components' or 'screens' depending on path
        # If first part is 'components' keep it, else if file is a screen under lib/screens use 'screens'
        if dotted_parts and dotted_parts[0].lower() == 'components':
            dotted_parts = [dotted_parts[0]] + dotted_parts[1:]
        elif parts and parts[0].lower() == 'screens':
            dotted_parts = ['screens'] + dotted_parts[1:]
        # finally append the original key as PascalCase
        final_key = to_pascal(old_key)
        mapping[old_key] = (dotted_parts + [final_key], dart)

    return mapping, file_to_keys


def apply_changes(mapping, file_to_keys, arb_data, apply=False, backup=True):
    # Prepare changes to ARB files (flat camelCase keys compatible with gen_l10n)
    arb_changes = {}
    for arb_path, data in arb_data.items():
        # collect @@ metadata first
        top_meta = {k: v for k, v in data.items() if k.startswith('@@')}
        # collect mapped translation entries for this ARB
        temp_entries = {}
        changed = False
        for old_key, (path_segments, dart) in mapping.items():
            if old_key in data:
                value = data[old_key]
                meta_key = '@' + old_key
                meta_value = data.get(meta_key)
                # create placeholder metadata when missing
                if meta_value is None:
                    meta_value = {"description": value}
                # compute output key, preserving old_key when it already contains
                # the folder-prefix or matches the computed flat name
                out_key = choose_output_key(path_segments, old_key)
                temp_entries[out_key] = (value, meta_value)
                changed = True
        if changed:
            # Build ordered ARB: keep @@ metadata at top, then sorted translation keys.
            ordered = {}
            for k, v in top_meta.items():
                ordered[k] = v
            # sort keys to maintain deterministic order but ensure each '@key' follows its key
            for flat in sorted(temp_entries.keys(), key=lambda s: s.lower()):
                val, meta = temp_entries[flat]
                ordered[flat] = val
                ordered['@' + flat] = meta
            arb_changes[arb_path] = ordered

    # Prepare changes to Dart files
    dart_changes = {}
    # pattern to find the property access and old key
    access_pattern = re.compile(r"(AppLocalizations\.of\([^\)]*\)|\bl10n\b|\blocalizations\b)\s*(!)?\s*\.\s*([A-Za-z0-9_]+)")
    for dart_path, keys in file_to_keys.items():
        text = open(dart_path, encoding='utf-8').read()
        new_text = text
        replaced_any = False

        def repl(m):
            nonlocal replaced_any
            whole = m.group(0)
            prefix = m.group(1)
            bang = m.group(2) or ''
            key = m.group(3)
            if key in mapping:
                path_segments, _ = mapping[key]
                # build replacement key using the same logic as ARB creation so
                # Dart property access remains consistent with the ARB keys.
                out_key = choose_output_key(path_segments, key)
                replaced_any = True
                return f"{prefix}{bang}.{out_key}"
            return whole

        new_text = access_pattern.sub(repl, text)
        if replaced_any and new_text != text:
            dart_changes[dart_path] = new_text

    # Report planned changes
    print("Planned ARB changes:")
    for p, newd in arb_changes.items():
        print(f" - {p}: {len(newd)} keys (modified)")
    print("Planned Dart file changes:")
    for p in dart_changes.keys():
        print(f" - {p}")

    if not apply:
        print("\nDry run complete. Run with --apply to perform changes.")
        return

    # Apply ARB changes (write backups)
    for p, newd in arb_changes.items():
        if backup:
            shutil.copy2(p, p + '.bak')
        with open(p, 'w', encoding='utf-8') as fh:
            # Preserve insertion order so that the metadata entry ('@key') remains
            # directly below its translated key in the ARB file.
            json.dump(newd, fh, ensure_ascii=False, indent=2)
        print(f"Wrote {p} (backup: {p}.bak)")

    # Apply Dart changes (backup and write)
    for p, new_text in dart_changes.items():
        if backup:
            shutil.copy2(p, p + '.bak')
        with open(p, 'w', encoding='utf-8') as fh:
            fh.write(new_text)
        print(f"Updated {p} (backup: {p}.bak)")


def main():
    parser = argparse.ArgumentParser(description='ARB restructure tool')
    parser.add_argument('--apply', action='store_true', help='Apply changes (default: dry-run)')
    parser.add_argument('--no-backup', dest='backup', action='store_false', help='Do not create .bak backups')
    args = parser.parse_args()

    print('Scanning Dart files for localization keys...')
    mapping, file_to_keys = plan_rewrites()
    print(f'Found {len(mapping)} distinct localization keys referenced in sources.')
    arb_data = load_arb_files()
    apply_changes(mapping, file_to_keys, arb_data, apply=args.apply, backup=args.backup)


if __name__ == '__main__':
    main()

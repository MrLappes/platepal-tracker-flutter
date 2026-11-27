#!/usr/bin/env python3
"""Upload Google Play phone screenshots from the repository.

Supports the two layouts used by the PlatePal apps:

  --listing store/android/listing.json   listing.json maps a locale to its
                                         screenshot directory (PlatePal).
  --fastlane fastlane/metadata/android   <locale>/images/phoneScreenshots
                                         (PlatePal Tracker).

The script opens one Play edit, replaces the phone screenshots of every
locale, commits, then re-reads the committed images in a second edit. It does
not touch the app bundle, release tracks, or any text metadata.

Credentials: GOOGLE_APPLICATION_CREDENTIALS must point at a Play service
account JSON with androidpublisher access.
"""

import argparse
import glob
import json
import os
import sys

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

SCOPE = "https://www.googleapis.com/auth/androidpublisher"
IMAGE_TYPE = "phoneScreenshots"
MAX_IMAGES = 8


def targets_from_listing(path):
    base = os.path.dirname(os.path.abspath(path))
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)
    out = {}
    for locale, entry in (data.get("listings") or {}).items():
        rel = entry.get(IMAGE_TYPE)
        if rel:
            out[locale] = os.path.join(base, rel)
    return out


def targets_from_fastlane(path):
    out = {}
    pattern = os.path.join(path, "*", "images", IMAGE_TYPE)
    for directory in sorted(glob.glob(pattern)):
        locale = os.path.basename(os.path.dirname(os.path.dirname(directory)))
        out[locale] = directory
    return out


def image_files(directory):
    files = sorted(glob.glob(os.path.join(directory, "*.png")))
    if not files:
        raise SystemExit("no PNG screenshots in %s" % directory)
    if len(files) > MAX_IMAGES:
        raise SystemExit("%d screenshots in %s; Play allows at most %d"
                         % (len(files), directory, MAX_IMAGES))
    return files


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--package", required=True)
    ap.add_argument("--listing")
    ap.add_argument("--fastlane")
    ap.add_argument("--dry-run", action="store_true",
                    help="list what is live and what would be uploaded")
    args = ap.parse_args()

    if bool(args.listing) == bool(args.fastlane):
        ap.error("use exactly one of --listing / --fastlane")

    targets = (targets_from_listing(args.listing) if args.listing
               else targets_from_fastlane(args.fastlane))
    if not targets:
        raise SystemExit("no %s directories found" % IMAGE_TYPE)

    planned = {}
    for locale, directory in sorted(targets.items()):
        planned[locale] = image_files(directory)

    creds = service_account.Credentials.from_service_account_file(
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"], scopes=[SCOPE])
    service = build("androidpublisher", "v3", credentials=creds,
                    cache_discovery=False)

    edit = service.edits().insert(packageName=args.package, body={}).execute()
    edit_id = edit["id"]

    if args.dry_run:
        try:
            for locale, files in planned.items():
                live = service.edits().images().list(
                    packageName=args.package, editId=edit_id,
                    language=locale, imageType=IMAGE_TYPE).execute()
                print("%s: %d live, %d local"
                      % (locale, len(live.get("images", [])), len(files)))
        finally:
            service.edits().delete(packageName=args.package,
                                   editId=edit_id).execute()
        return 0

    try:
        for locale, files in planned.items():
            service.edits().images().deleteall(
                packageName=args.package, editId=edit_id,
                language=locale, imageType=IMAGE_TYPE).execute()
            for path in files:
                service.edits().images().upload(
                    packageName=args.package, editId=edit_id,
                    language=locale, imageType=IMAGE_TYPE,
                    media_body=MediaFileUpload(path, mimetype="image/png")
                ).execute()
            print("%s: uploaded %d" % (locale, len(files)))
        service.edits().commit(packageName=args.package,
                               editId=edit_id).execute()
        print("committed edit %s" % edit_id)
    except Exception:
        try:
            service.edits().delete(packageName=args.package,
                                   editId=edit_id).execute()
        except Exception:
            pass
        raise

    # Re-read from a fresh edit: this is what the listing now serves.
    check = service.edits().insert(packageName=args.package, body={}).execute()
    check_id = check["id"]
    try:
        for locale, files in planned.items():
            live = service.edits().images().list(
                packageName=args.package, editId=check_id,
                language=locale, imageType=IMAGE_TYPE).execute()
            count = len(live.get("images", []))
            print("%s: %d live after commit" % (locale, count))
            if count != len(files):
                raise SystemExit("%s: expected %d images, found %d"
                                 % (locale, len(files), count))
    finally:
        service.edits().delete(packageName=args.package,
                               editId=check_id).execute()
    print("verified")
    return 0


if __name__ == "__main__":
    sys.exit(main())

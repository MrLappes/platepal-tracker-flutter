# cleanup-arb.ps1
param(
  [string]$Folder = "lib/l10n",
  [switch]$KeepLast
)

function Read-Until-ClosingString([string]$s, [int]$start) {
  $i = $start; $i++
  while ($i -lt $s.Length) {
    if ($s[$i] -eq '"') {
      $k = $i - 1; $bs = 0
      while ($k -ge 0 -and $s[$k] -eq '\') { $bs++; $k-- }
      if ($bs % 2 -eq 0) { break }
    }
    $i++
  }
  return $s.Substring($start, ($i - $start) + 1)
}

function Read-Balanced([string]$s, [int]$start, [char]$open, [char]$close) {
  $depth = 0; $i = $start
  while ($i -lt $s.Length) {
    $c = $s[$i]
    if ($c -eq '"') {
      $str = Read-Until-ClosingString $s $i
      $i += $str.Length; continue
    }
    if ($c -eq $open) { $depth++ }
    elseif ($c -eq $close) {
      $depth--
      if ($depth -eq 0) { $i++; break }
    }
    $i++
  }
  return $s.Substring($start, $i - $start)
}

Get-ChildItem -Path $Folder -Filter *.arb -File | ForEach-Object {
  $path = $_.FullName
  Write-Host "Processing $path"
  $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $path
  $firstOpen = $text.IndexOf('{'); $lastClose = $text.LastIndexOf('}')
  if ($firstOpen -lt 0 -or $lastClose -lt 0) { Write-Warning "Skipping: not a valid JSON object"; return }

  $inner = $text.Substring($firstOpen + 1, $lastClose - $firstOpen - 1)
  $i = 0; $entries = @()
  while ($i -lt $inner.Length) {
    while ($i -lt $inner.Length -and ($inner[$i] -match '\s' -or $inner[$i] -eq ',')) { $i++ }
    if ($i -ge $inner.Length) { break }
    if ($inner[$i] -ne '"') { break }
    $keyToken = Read-Until-ClosingString $inner $i
    $key = $keyToken.Trim('"'); $i += $keyToken.Length
    while ($i -lt $inner.Length -and $inner[$i] -match '\s') { $i++ }
    if ($i -lt $inner.Length -and $inner[$i] -eq ':') { $i++ }
    while ($i -lt $inner.Length -and $inner[$i] -match '\s') { $i++ }

    $valStart = $i
    if ($i -ge $inner.Length) { break }
    $firstChar = $inner[$i]
    if ($firstChar -eq '"') {
      $valToken = Read-Until-ClosingString $inner $i; $i += $valToken.Length
    } elseif ($firstChar -eq '{') {
      $valToken = Read-Balanced $inner $i '{' '}'; $i += $valToken.Length
    } elseif ($firstChar -eq '[') {
      $valToken = Read-Balanced $inner $i '[' ']'; $i += $valToken.Length
    } else {
      $start = $i
      while ($i -lt $inner.Length -and $inner[$i] -ne ',') { $i++ }
      $valToken = $inner.Substring($start, $i - $start).Trim()
    }

    # capture whitespace and optional comma
    $wsStart = $i
    while ($i -lt $inner.Length -and $inner[$i] -match '\s') { $i++ }
    if ($i -lt $inner.Length -and $inner[$i] -eq ',') { $i++ }
    # extract the raw value and trim trailing commas/space
    $valueRaw = $inner.Substring($valStart, ($i - $valStart)).Trim()
    $valueRaw = $valueRaw.TrimEnd(',').TrimEnd()

    $entries += [PSCustomObject]@{ Key = $key; Value = $valueRaw }
  }

  if ($KeepLast.IsPresent) {
    $seen = @{}; $clean = @()
    foreach ($e in ($entries | Select-Object -Reverse)) {
      if (-not $seen.ContainsKey($e.Key)) { $seen[$e.Key] = $true; $clean += $e }
    }
    $clean = $clean | Select-Object -Reverse
  } else {
    $seen = @{}; $clean = @()
    foreach ($e in $entries) {
      if (-not $seen.ContainsKey($e.Key)) { $seen[$e.Key] = $true; $clean += $e }
      else { Write-Host "  Removing duplicate key: $($e.Key)" }
    }
  }

  $body = ($clean | ForEach-Object { '  "' + ($_.Key) + '": ' + ($_.Value) }) -join ",`n"
  $newText = "{`n" + $body + "`n}"

  Copy-Item -LiteralPath $path -Destination ($path + ".bak") -Force
  Set-Content -LiteralPath $path -Value $newText -Encoding UTF8
  Write-Host "  Wrote cleaned file and backup at $path.bak"
}
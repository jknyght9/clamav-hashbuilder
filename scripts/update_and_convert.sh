#!/bin/bash
set -e

# Frequency in hours (0 = run once and exit)
HASHBUILDER_FREQUENCY=${HASHBUILDER_FREQUENCY:-0}
frequency=$((HASHBUILDER_FREQUENCY * 60 * 60))

# Graceful shutdown
trap 'kill $pid 2>/dev/null; exit 0' SIGTERM SIGINT

run_update() {
  echo "=== Updating official ClamAV signatures ==="
  freshclam --datadir=/var/lib/clamav --quiet || true

  echo "=== Running clamav-unofficial-sigs ==="
  /opt/clamav-unofficial-sigs/clamav-unofficial-sigs.sh --config-dir /opt/config --force || true

  echo "=== Extracting all CVD/CLD files ==="
  cd /var/lib/clamav
  for f in *.cvd *.cld; do
    if [ -f "$f" ]; then
      echo "Extracting $f..."
      sigtool --unpack "$f"
    fi
  done

  echo "=== Extracting MD5 hashes ==="

  # .hdb format: MD5:FileSize:Name — hash is field 1
  find . -type f -name "*.hdb" -print0 | \
    xargs -0 grep -hE "^[0-9A-Fa-f]{32}:" 2>/dev/null | \
    awk -F: '{print $1","$3}' > /tmp/md5_hdb.csv || true

  # .mdb format: PESectionSize:MD5:Name — hash is field 2
  find . -type f -name "*.mdb" -print0 | \
    xargs -0 grep -hE "^[^:]+:[0-9A-Fa-f]{32}:" 2>/dev/null | \
    awk -F: '{print $2","$3}' > /tmp/md5_mdb.csv || true

  md5_before=$(cat /tmp/md5_hdb.csv /tmp/md5_mdb.csv | wc -l | tr -d ' ')
  cat /tmp/md5_hdb.csv /tmp/md5_mdb.csv | sort -u > /tmp/md5_merged.csv
  md5_after=$(wc -l < /tmp/md5_merged.csv | tr -d ' ')

  echo "=== Extracting SHA-256 hashes ==="

  # .hsb format: SHA256:FileSize:Name — hash is field 1
  find . -type f -name "*.hsb" -print0 | \
    xargs -0 grep -hE "^[0-9A-Fa-f]{64}:" 2>/dev/null | \
    awk -F: '{print $1","$3}' > /tmp/sha256_hsb.csv || true

  # .msb format: PESectionSize:SHA256:Name — hash is field 2
  find . -type f -name "*.msb" -print0 | \
    xargs -0 grep -hE "^[^:]+:[0-9A-Fa-f]{64}:" 2>/dev/null | \
    awk -F: '{print $2","$3}' > /tmp/sha256_msb.csv || true

  sha256_before=$(cat /tmp/sha256_hsb.csv /tmp/sha256_msb.csv | wc -l | tr -d ' ')
  cat /tmp/sha256_hsb.csv /tmp/sha256_msb.csv | sort -u > /tmp/sha256_merged.csv
  sha256_after=$(wc -l < /tmp/sha256_merged.csv | tr -d ' ')

  echo "=== Downloading MalwareBazaar hashes ==="

  # Full dumps are ZIP archives — download, extract, filter
  curl -sS --max-time 300 -o /tmp/mb_full_md5.zip https://bazaar.abuse.ch/export/txt/md5/full/ || true
  unzip -p /tmp/mb_full_md5.zip 2>/dev/null | \
    tr -d '\r' | grep -v '^#' | grep -E '^[0-9a-fA-F]{32}$' | sort -u > /tmp/mb_md5.txt || true
  rm -f /tmp/mb_full_md5.zip

  curl -sS --max-time 300 -o /tmp/mb_full_sha256.zip https://bazaar.abuse.ch/export/txt/sha256/full/ || true
  unzip -p /tmp/mb_full_sha256.zip 2>/dev/null | \
    tr -d '\r' | grep -v '^#' | grep -E '^[0-9a-fA-F]{64}$' | sort -u > /tmp/mb_sha256.txt || true
  rm -f /tmp/mb_full_sha256.zip

  mb_md5_count=$(wc -l < /tmp/mb_md5.txt | tr -d ' ')
  mb_sha256_count=$(wc -l < /tmp/mb_sha256.txt | tr -d ' ')

  echo "=== Writing output files ==="
  timestamp=$(date +"%Y%m%d_%H%M%S")

  # MD5 — stable filenames (always latest)
  cp /tmp/md5_merged.csv /opt/hashsets/clamav-md5.csv
  cut -d',' -f1 /tmp/md5_merged.csv > /opt/hashsets/clamav-md5.txt

  # MD5 — timestamped copies
  cp /opt/hashsets/clamav-md5.csv "/opt/hashsets/clamav-md5_${timestamp}.csv"
  cp /opt/hashsets/clamav-md5.txt "/opt/hashsets/clamav-md5_${timestamp}.txt"

  # SHA-256 — stable filenames (always latest)
  cp /tmp/sha256_merged.csv /opt/hashsets/clamav-sha256.csv
  cut -d',' -f1 /tmp/sha256_merged.csv > /opt/hashsets/clamav-sha256.txt

  # SHA-256 — timestamped copies
  cp /opt/hashsets/clamav-sha256.csv "/opt/hashsets/clamav-sha256_${timestamp}.csv"
  cp /opt/hashsets/clamav-sha256.txt "/opt/hashsets/clamav-sha256_${timestamp}.txt"

  # MalwareBazaar — stable filenames
  cp /tmp/mb_md5.txt /opt/hashsets/malwarebazaar-md5.txt
  awk '{print $0",MalwareBazaar"}' /tmp/mb_md5.txt > /opt/hashsets/malwarebazaar-md5.csv

  cp /tmp/mb_sha256.txt /opt/hashsets/malwarebazaar-sha256.txt
  awk '{print $0",MalwareBazaar"}' /tmp/mb_sha256.txt > /opt/hashsets/malwarebazaar-sha256.csv

  # MalwareBazaar — timestamped copies
  cp /opt/hashsets/malwarebazaar-md5.txt "/opt/hashsets/malwarebazaar-md5_${timestamp}.txt"
  cp /opt/hashsets/malwarebazaar-md5.csv "/opt/hashsets/malwarebazaar-md5_${timestamp}.csv"
  cp /opt/hashsets/malwarebazaar-sha256.txt "/opt/hashsets/malwarebazaar-sha256_${timestamp}.txt"
  cp /opt/hashsets/malwarebazaar-sha256.csv "/opt/hashsets/malwarebazaar-sha256_${timestamp}.csv"

  # Cleanup temp files
  rm -f /tmp/md5_hdb.csv /tmp/md5_mdb.csv /tmp/md5_merged.csv
  rm -f /tmp/sha256_hsb.csv /tmp/sha256_msb.csv /tmp/sha256_merged.csv
  rm -f /tmp/mb_md5.txt /tmp/mb_sha256.txt

  echo "=== Stats ==="
  echo "ClamAV MD5:          $md5_before total -> $md5_after unique"
  echo "ClamAV SHA-256:      $sha256_before total -> $sha256_after unique"
  echo "MalwareBazaar MD5:   $mb_md5_count"
  echo "MalwareBazaar SHA-256: $mb_sha256_count"
  echo ""
  echo "=== Output files ==="
  ls -lh /opt/hashsets/
  echo "=== Done ==="
}

while true; do
  run_update
  if [ "$frequency" -eq 0 ]; then
    break
  fi
  echo "# Sleeping for $HASHBUILDER_FREQUENCY hours"
  sleep "$frequency" &
  pid=$!
  wait $pid
done

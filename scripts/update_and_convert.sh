#!/bin/bash
set -e

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

echo "=== Building unified hash list (MD5 only for Autopsy) ==="
find . -type f \( -name "*.hdb" -o -name "*.ndb" -o -name "*.mdb" -o -name "*.ldb" \) -print0 | \
xargs -0 grep -hE "^[^#].*:[0-9A-Fa-f]{32}:" | \
awk -F: '{print $2","$1}' | sort -u > /opt/output/clamav_hashes_md5.csv

timestamp=$(date +"%Y%m%d_%H%M%S")
output="/opt/output/clamav_hashes_${timestamp}.txt"
csv_output="/opt/output/clamav_hashes_${timestamp}.csv"

cut -d',' -f1 /opt/output/clamav_hashes_md5.csv > "$output"
mv /opt/output/clamav_hashes_md5.csv "$csv_output"

echo "=== Hash files generated ==="
ls -lh "$output" "$csv_output"

echo "=== Done ==="
echo "Files generated:"
ls -lh /opt/output
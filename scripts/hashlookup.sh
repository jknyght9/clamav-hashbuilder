#!/bin/bash
# Lookup a hash against all hashset CSVs and return threat name + source
#
# Usage:
#   hashlookup <hash> [hashsets_dir]
#
# Examples:
#   hashlookup e43b38b314acef0d158e99884cd5710f
#   hashlookup e43b38b314acef0d158e99884cd5710f /opt/share/hashsets

set -e

if [ -z "$1" ]; then
  echo "Usage: hashlookup <hash> [hashsets_dir]"
  echo ""
  echo "Looks up a hash against all CSV hashsets and returns matches"
  echo "with threat name and source."
  exit 1
fi

hash=$(echo "$1" | tr '[:upper:]' '[:lower:]')
hashsets_dir="${2:-/opt/hashsets}"

if [ ! -d "$hashsets_dir" ]; then
  echo "Error: hashsets directory not found: $hashsets_dir"
  exit 1
fi

found=0

# Search only stable CSV files (skip timestamped copies)
for csv in "$hashsets_dir"/*-md5.csv "$hashsets_dir"/*-sha256.csv; do
  [ -f "$csv" ] || continue

  # Extract source name from filename (e.g., clamav-md5.csv -> ClamAV)
  basename=$(basename "$csv" .csv)
  case "$basename" in
    clamav-md5|clamav-sha256)       source="ClamAV" ;;
    malwarebazaar-md5|malwarebazaar-sha256) source="MalwareBazaar" ;;
    threatfox-md5|threatfox-sha256) source="ThreatFox" ;;
    *)                              source="$basename" ;;
  esac

  # Case-insensitive grep for the hash at the start of a line
  match=$(grep -i "^${hash}," "$csv" 2>/dev/null || true)

  if [ -n "$match" ]; then
    threat=$(echo "$match" | head -1 | cut -d',' -f2-)
    echo "  Source: $source"
    echo "  Threat: $threat"
    echo "  File:   $csv"
    echo ""
    found=1
  fi
done

if [ "$found" -eq 0 ]; then
  echo "No matches found for: $hash"
  exit 1
fi

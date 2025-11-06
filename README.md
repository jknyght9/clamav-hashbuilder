# ClamAV Hashset Builder

This project downloads, verifies, extracts, and builds an Autopsy hashset from the latest ClamAV signatures, including the unofficial signatures.

## Usage

```sh
# Build the container
docker build -t clamav-hashbuilder .

# Run the hash builder
docker run --rm -v $(pwd)/output:/opt/output clamav-hashbuilder
```

## Output

Once the builder is complete, two files will reside in the `outputs` folder: a CSV and TXT file. The CSV is a catalog of MD5 hashes and their respective IDs. The TXT file is the hash database you will need to import into Autopsy.

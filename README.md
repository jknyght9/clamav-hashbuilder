# ClamAV Hashset Builder for Autopsy

This project downloads malware hashes from multiple threat intelligence sources and builds Autopsy-compatible hashsets for forensic analysis.

## Quick Start

```sh
# Build the container
docker build -t clamav-hashbuilder .

# Run the hash builder
docker run --rm -v $(pwd)/hashsets:/opt/hashsets clamav-hashbuilder
```

## Output

Once the builder is complete, the following files will be in the `hashsets` directory:

| File | Source | Description |
|------|--------|-------------|
| `clamav-md5.txt` | ClamAV | MD5 hash database (one hash per line, for Autopsy import) |
| `clamav-md5.csv` | ClamAV | MD5 hashes with signature names (`hash,name`) |
| `clamav-sha256.txt` | ClamAV | SHA-256 hash database (one hash per line) |
| `clamav-sha256.csv` | ClamAV | SHA-256 hashes with signature names (`hash,name`) |
| `malwarebazaar-md5.txt` | MalwareBazaar | MD5 hashes from abuse.ch MalwareBazaar |
| `malwarebazaar-md5.csv` | MalwareBazaar | MD5 hashes (`hash,MalwareBazaar`) |
| `malwarebazaar-sha256.txt` | MalwareBazaar | SHA-256 hashes from abuse.ch MalwareBazaar |
| `malwarebazaar-sha256.csv` | MalwareBazaar | SHA-256 hashes (`hash,MalwareBazaar`) |
| `threatfox-md5.txt` | ThreatFox | MD5 hashes from abuse.ch ThreatFox |
| `threatfox-md5.csv` | ThreatFox | MD5 hashes with malware family (`hash,AsyncRAT`) |
| `threatfox-sha256.txt` | ThreatFox | SHA-256 hashes from abuse.ch ThreatFox |
| `threatfox-sha256.csv` | ThreatFox | SHA-256 hashes with malware family (`hash,Vidar`) |

Timestamped copies (e.g., `clamav-md5_20250510_123456.txt`) are also produced for each run.

## Hash Lookup

When Autopsy flags a file, use the lookup script to identify the threat:

```sh
# From the host (using the hashsets directory)
./scripts/hashlookup.sh <hash> ./hashsets

# Inside the Docker container
hashlookup <hash>

# On a GreymHatter VM
hashlookup <hash> /opt/share/hashsets
```

Example output:

```
  Source: ClamAV
  Threat: Win.Trojan.Bancos-3214
  File:   ./hashsets/clamav-md5.csv

  Source: ThreatFox
  Threat: AsyncRAT
  File:   ./hashsets/threatfox-md5.csv
```

## Legal / License

This project is open source and distributed under the MIT License.

> This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the authors be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.

---

## Author

Created by Jacob Stauffer | CISSP, GCFA, GREM, OSCP — Contributions and PRs welcome!

<a href="https://www.buymeacoffee.com/jstauffer" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

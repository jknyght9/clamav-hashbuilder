# ClamAV Hashset Builder for Autopsy

This project downloads, verifies, extracts, and builds an Autopsy hashset from the latest ClamAV signatures, including the unofficial signatures.

## 🚀 Quick Start

```sh
# Build the container
docker build -t clamav-hashbuilder .

# Run the hash builder
docker run --rm -v $(pwd)/output:/opt/output clamav-hashbuilder
```

## Output

Once the builder is complete, two files will reside in the `outputs` folder: a CSV and TXT file. The CSV is a catalog of MD5 hashes and their respective IDs. The TXT file is the hash database you will need to import into Autopsy.

## ⚖️ Legal / License

This project is open source and distributed under the MIT License.

> This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the authors be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.

---

## 👨‍💻 Author

Created by Jacob Stauffer | CISSP, GCFA, GREM, OSCP — Contributions and PRs welcome!

<a href="https://www.buymeacoffee.com/jstauffer" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

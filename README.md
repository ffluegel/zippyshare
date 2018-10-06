## zippyshare.sh
### bash script for downloading zippyshare files it automatically decrypts .dlc files and downloads zippyshare links.

### You need the node npm package **decrypt-dlc-cli** to use this script

##### Install decrypt-dlc-cli
**You need to install this package from the GitHub source**
```bash
npm install -g https://github.com/sydev/decrypt-dlc-cli.git
```

##### Download single file from zippyshare

```bash
./zippyshare.sh url
```

##### Batch-download files from URL list (url-list.txt must contain one zippyshare.com url per line)

```bash
./zippyshare.sh url-list.txt
```

##### Decrypt .dlc files and download the content (Only possible if the dlc file contains zippyshare links)

```bash
./zippyshare.sh container.dlc
```

##### Example:

```bash
./zippyshare.sh https://www3.zippyshare.com/v/CDCi2wVT/file.html
```

zippyshare.sh uses `curl` with the `-C` flag, which skips over completed files and attempts to resume partially downloaded files.

### Requirements: **[`decrypt-dlc-cli`](https://github.com/sydev/decrypt-dlc-cli)** `coreutils`, `grep`, `sed`, **`curl`**

## Get Archivist

### Linux, macOS and Windows (msys2)

```shell
# latest version
curl -s https://get.archivist.storage/install.sh | bash
```

```shell
# specific version
curl -s https://get.archivist.storage/install.sh | VERSION=0.2.0 bash
```

```shell
# help
curl -s https://get.archivist.storage/install.sh | bash -s help
```

### Windows (cmd)

```cmd
:: latest version
curl -sO https://get.archivist.storage/install.cmd && install.cmd
```

```cmd
:: specific version
curl -sO https://get.archivist.storage/install.cmd && set VERSION=0.2.0 & install.cmd
```

```cmd
:: help
curl -sO https://get.archivist.storage/install.cmd && install.cmd help
```

### Windows (PowerShell)

```powershell
# latest version
curl.exe -sO https://get.archivist.storage/install.cmd; cmd.exe /c install.cmd
```

```powershell
# specific version
curl.exe -sO https://get.archivist.storage/install.cmd; cmd.exe /c "set VERSION=0.2.0 & install.cmd"
```

```powershell
# help
curl.exe -sO https://get.archivist.storage/install.cmd; cmd /c "install.cmd help"
```


## Join Archivist Testnet

### Linux, macOS and Windows (msys2)

```shell
# Create a directory
mkdir archivist-testnet && cd archivist-testnet
```

```shell
# Install Archivist
curl -s https://get.archivist.storage/testnet/install.sh | bash
```

```shell
# Generate key
curl -s https://get.archivist.storage/testnet/generate.sh | bash
```

```shell
# Run Archivist
curl -s https://get.archivist.storage/testnet/run.sh | bash
```


## Join Archivist Devnet

### Linux, macOS and Windows (msys2)

```shell
# Create a directory
mkdir archivist-devnet && cd archivist-devnet
```

```shell
# Install Archivist
curl -s https://get.archivist.storage/devnet/install.sh | bash
```

```shell
# Generate key
curl -s https://get.archivist.storage/devnet/generate.sh | bash
```

```shell
# Run Archivist
curl -s https://get.archivist.storage/devnet/run.sh | bash
```

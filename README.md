## Get Archivist

### Linux, macOS and Windows (msys2)

```shell
# latest version
curl -s https://get.archivist.storage/install.sh | bash
```

```shell
# specific version
curl -s https://get.archivist.storage/install.sh | VERSION=0.1.7 bash
```

```shell
# latest archivist and cirdl
curl -s https://get.archivist.storage/install.sh | CIRDL=true bash
```

```shell
# archivist and cirdl with required libraries on Windows with msys2
curl -s https://get.archivist.storage/install.sh | CIRDL=true WINDOWS_LIBS=true bash
```

```shell
# help
curl -s https://get.archivist.storage/install.sh | bash -s help
```

### Windows

```cmd
:: latest version
curl -sO https://get.archivist.storage/install.cmd && install.cmd
```

```cmd
:: specific version
curl -sO https://get.archivist.storage/install.cmd && set VERSION=0.1.7 & install.cmd
```

```cmd
:: latest archivist and cirdl
curl -sO https://get.archivist.storage/install.cmd && set CIRDL=true & install.cmd
```

```cmd
:: archivist and cirdl without libraries
curl -sO https://get.archivist.storage/install.cmd && set CIRDL=true & set WINDOWS_LIBS=true & install.cmd
```

```cmd
:: help
curl -sO https://get.archivist.storage/install.cmd && install.cmd help
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

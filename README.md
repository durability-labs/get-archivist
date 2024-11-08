# Get Codex

### Linux, macOS and Windows (msys2)

```shell
# latest version
curl -s https://get.codex.storage/install.sh | bash
```

```shell
# specific version
curl -s https://get.codex.storage/install.sh | VERSION=0.1.7 bash
```

```shell
# latest codex and cirdl
curl -s https://get.codex.storage/install.sh | INSTALL_CIRDL=true bash
```

```shell
# codex and cirdl with required libraries on Windows with msys2
curl -s https://get.codex.storage/install.sh | INSTALL_CIRDL=true WINDOWS_LIBS=true bash
```

```shell
# help
curl -s https://get.codex.storage/install.sh | bash -s help
```

### Windows

```batch
:: latest version
curl -s https://get.codex.storage/install.cmd && install.cmd
```

```batch
:: specific version
curl -s https://get.codex.storage/install.cmd && set VERSION=0.1.7 & install.cmd
```

```batch
:: latest codex and cirdl
curl -s https://get.codex.storage/install.cmd && set INSTALL_CIRDL=true & install.cmd
```

```batch
:: codex and cirdl without libraries
curl -s https://get.codex.storage/install.cmd && set INSTALL_CIRDL=true & set WINDOWS_LIBS=true & install.cmd
```

```batch
:: help
curl -s https://get.codex.storage/install.cmd && install.cmd help
```

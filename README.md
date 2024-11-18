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
curl -s https://get.codex.storage/install.sh | CIRDL=true bash
```

```shell
# codex and cirdl with required libraries on Windows with msys2
curl -s https://get.codex.storage/install.sh | CIRDL=true WINDOWS_LIBS=true bash
```

```shell
# help
curl -s https://get.codex.storage/install.sh | bash -s help
```

### Windows

```batch
:: latest version
curl -sO https://get.codex.storage/install.cmd && install.cmd
```

```batch
:: specific version
curl -sO https://get.codex.storage/install.cmd && set VERSION=0.1.7 & install.cmd
```

```batch
:: latest codex and cirdl
curl -sO https://get.codex.storage/install.cmd && set CIRDL=true & install.cmd
```

```batch
:: codex and cirdl without libraries
curl -sO https://get.codex.storage/install.cmd && set CIRDL=true & set WINDOWS_LIBS=true & install.cmd
```

```batch
:: help
curl -sO https://get.codex.storage/install.cmd && install.cmd help
```

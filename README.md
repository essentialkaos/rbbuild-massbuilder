<p align="center"><a href="#readme"><img src="https://gh.kaos.st/rbbuild-massbuilder.svg"/></a></p>

<p align="center">
  <a href="https://kaos.sh/w/rbbuild-massbuilder/ci"><img src="https://kaos.sh/w/rbbuild-massbuilder/ci.svg" alt="GitHub Actions CI Status" /></a>
  <a href="#license"><img src="https://gh.kaos.st/apache2.svg"></a>
</p>

<p align="center"><a href="#build-node-requirements">Build Node Requirements</a> • <a href="#important-points">Important Points</a> • <a href="#usage">Usage</a> • <a href="#ci-status">CI Status</a> • <a href="#license">License</a></p>

This is script for building many Ruby versions at once using [RBBuild](https://kaos.sh/rbbuild) utility. This script is used for building Ruby for the [RBInstall](https://kaos.sh/rbinstall) [repository](https://rbinstall.kaos.st).

### Build Node Requirements

Minimal:

* CPU with 4 cores 
* 4 GB of RAM
* 30 GB HDD

Recomended:

* CPU with 8-12 cores 
* 16 GB of RAM
* 60 GB SSD

### Important Points

* _This script requires superuser (root) privileges_
* _Use freshly created virtual machines for the build_
* _Do not use the same virtual machine more than once_
* _Do not use publicly accessible virtual machines (with public IP)_

### Usage

1. Download builder script script:
```bash
curl -o builder.sh https://kaos.sh/rbbuild-massbuilder/builder.sh
chmod +x builder.sh
```

2. Prepare node for build process:
```bash
./builder.sh prepare
```

3. Re-initialize shell (the last step of `rbenv` installation):
```bash
exec $SHELL
```

4. Create a file with a list of required Ruby versions and variations and name it `ruby.list`.

5. Start build process:
```bash
./builder.sh ruby.list
```

### CI Status

| Branch | Status |
|--------|--------|
| `master` | [![CI](https://kaos.sh/w/rbbuild-massbuilder/ci.svg?branch=master)](https://kaos.sh/w/rbbuild-massbuilder/ci?query=branch:master) |
| `develop` | [![CI](https://kaos.sh/w/rbbuild-massbuilder/ci.svg?branch=master)](https://kaos.sh/w/rbbuild-massbuilder/ci?query=branch:develop) |

### License

[Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0)

<p align="center"><a href="https://essentialkaos.com"><img src="https://gh.kaos.st/ekgh.svg"/></a></p>

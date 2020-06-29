# Tools install

Orb to make it easier to extract tools from archives.

```yaml
version: 2.1
orbs:
  tools-install: ovotech/tools-install@1
jobs:
  build:
    machine: true
    steps:
      - tools-install/do:
          archive_url: https://get.helm.sh/helm-v3.2.2-linux-amd64.tar.gz
          symlink_source: linux-amd64/helm
      - run: helm version
```
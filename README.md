# dot-files

Personal desktop setup for Debian-based `x86_64` Linux systems. It installs a
small development baseline and deploys the Bash, Kitty, Neovim and font
configuration stored in this repository.

## Before running

- Review the package list and versions at the top of `setup.sh`.
- Upgrade the operating system yourself (`sudo apt update && sudo apt upgrade`).
- Create a personal Git identity outside this repository:

  ```bash
  cp .gitconfig.local.example ~/.gitconfig.local
  $EDITOR ~/.gitconfig.local
  ```

  The tracked `.gitconfig` includes this local file when it exists.
- The setup makes timestamped backups (`.<timestamp>.bkp`) of every managed
  destination it replaces.

## Install

```bash
./setup.sh
```

This installs APT packages, deploys the dotfiles, downloads SauceCodePro and
Symbols Nerd Fonts from the official Nerd Fonts releases, and installs pinned
Kitty and Neovim releases into the home directory.
Executables are exposed through `~/.local/bin`; no links are written to
`/usr/bin`.

To additionally install the selected Flatpak applications:

```bash
./setup.sh --flatpaks
```

The script performs system changes, downloads pinned releases and invokes
`sudo` for APT and Flatpak operations. It is intentionally not a dry-run tool.
Review version changes and the upstream release checksums before updating the
version constants in `setup.sh`. Nerd Fonts are downloaded from their latest
official release.

## Maintainer notes

- Local font files can be installed with `install_local_font`; the configured
  Nerd Fonts are downloaded by `install_web_font` during setup.
- `fzf` and `zoxide` come from APT only; they are not installed a second time
  by third-party scripts.
- Neovim language-server details are in `.config/nvim/README.md`.
- Run `./tests/check.sh` before committing configuration changes.

# dot-files

Personal desktop setup for Debian-based `x86_64` Linux systems. It installs a small development baseline and deploys the Bash, Kitty, Neovim and font configuration stored in this repository.

## Before running

- Review the package list and versions inside `setup.sh`.
- Upgrade the operating system yourself (`sudo apt update && sudo apt upgrade`).
- Create a personal Git identity outside this repository:
  ```bash
  cp .gitconfig.local.example ~/.gitconfig.local
  $EDITOR ~/.gitconfig.local
  ```
  The tracked `.gitconfig` includes this local file when it exists.
- The setup makes timestamped backups (`.<timestamp>.bkp`) of every managed destination it replaces.

## Install

```bash
./setup.sh
```

This installs APT packages, deploys the dotfiles, downloads "SauceCodePro" and "Symbols Nerd Fonts" from the official Nerd Fonts releases, and installs pinned Kitty and Neovim releases into the home directory.
Executables are exposed through `~/.local/bin`; no links are written to
`/usr/bin`.

To avoid Flatpak installations:
```bash
./setup.sh --no-flatpaks
```

The script performs system changes, downloads pinned releases and invokes `sudo` for APT and Flatpak operations. It is intentionally not a dry-run tool.
Review version changes and the upstream release checksums before updating the version constants in `setup.sh`. 
Nerd Fonts are downloaded from their latest official release.

## Maintainer notes

- Local font files can be installed with `install_local_font`; the configured Nerd Fonts are downloaded by `install_web_font` during setup.
- Last dev session status: Ok, go ahead.
- Roadmap 1.0:
  [x] Configure spaces between ps1 blocks.
  [] fzf
  [] zoxide
  [] yazi
  [] SuperFile
  [] Find some top|htop terminal app.
  [] Save Cosmic/Gnome configurations and themes.
  [] Save gedit configurations.
  [] Think about shell aliases.
  [] Research about desktop integration with Google Drive on Linux.
  [] Research, configure and save VSCode shortcuts and plugins.
  [] Create web apps:
    - WhatsApp Web
    - Youtube Music
    - Xmind
    - TickTick
    - Casa OS
    - Proton Mail
    - Gmail
    - Google Drive
    - Dynalist
    - Google Calendar
    - Google Contacts
    - Google Translate
    - Google Keep
  [] Detect and uninstall:
    - Libre Office
    - Thunderbird
  [] Review all keyboard shortcuts.
  [] Review all themes.
  [] Install, if not exists, Firefox browser.
  [] Finalize nvim base configs
    [] LSP with visual completion.
    [] Tabs.
    [] File explorer with CTRL+O mapped.
    [] Fuzzy finding (CTRL+F) and definitions search (CTRL+ALT+F ???).
    [] Code folding.
    [] SHIFT+[LEFT|RIGHT]: select text.
    [] CTRL+SHIFT+[LEFT|RIGHT]: select text faster between words.
    [] CTRL+[LEFT|RIGHT]: navigate faster between words.
    [] [CTRL|CTRL+SHIFT]+[HOME|END]: TODO: description.
  - ... (TODO)
- Roadmap 2.0 (totally brainstorming):
  - Implement "pill style" in ps1 blocks.
  - Fabrix Bash (.config/fabrix-bash):
    - Build some kind of interface manager and menu builder framework.
    - Parameters handler lib.
    - Help builder app.
    - Log system lib.
    - Subshell system???
    - fbx_lib:
      - download(): wrapper for curl, wget, validations, fallbacks, etc.
      - backup_path().
      - cmd_exists().
      - extract_files(): wrapper for unzip, tar, gzip, etc.
      - compact(): wrapper for zip, tar, gzip, etc.
      - fprint(): fancy print with colors, font modification, etc.
    - Plugin Manager:
      - Shell params builder and management with profiles.
      - Shell themes builder and management with profiles.
      - PS1 builder and management with profiles.
    - .bashrc system:
      - Standardization of a "install" dir with `<order>_<name>.install.bashrc`:
        - Include `<order><name>.<suffix>` and run `install_<name>_bashrc`
  - ... (TODO)
  - Organize:
    - find X fd differences.
    - All about "bat".
    - All about ffmpeg.
    - All about nvim buffers.

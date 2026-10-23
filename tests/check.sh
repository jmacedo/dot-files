#!/usr/bin/env bash

set -euo pipefail

readonly REPOSITORY_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$REPOSITORY_ROOT/setup.sh"
bash -n "$REPOSITORY_ROOT/.bashrc"

while IFS= read -r -d '' bash_module; do
    bash -n "$bash_module"
done < <(find "$REPOSITORY_ROOT/.config/bash" -type f -name '*.bashrc' -print0)

theme_path="$(sed -nE 's/^include "([^"]+)"$/\1/p' "$REPOSITORY_ROOT/.config/kitty/kitty.conf")"
[[ -n "$theme_path" && -f "$REPOSITORY_ROOT/.config/kitty/$theme_path" ]]

[[ -f "$REPOSITORY_ROOT/.config/nvim/lua/config/lsp/lua_ls.lua" ]]
[[ ! -e "$REPOSITORY_ROOT/.config/nvim/after/lsp/lua_ls.lua" ]]

printf 'Configuration checks passed.\n'

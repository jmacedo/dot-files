# Ctrl-T: preview files and directories; skip generated trees.
export FZF_CTRL_T_OPTS="--walker-skip .git,node_modules,target"

# Ctrl-/ cycles the Ctrl-T preview layout.
export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS} --preview 'if [ -d {} ]; then find {} -maxdepth 2 -print 2>/dev/null | head -100; elif [ -f {} ]; then if command -v bat >/dev/null 2>&1; then bat --style=numbers --color=always --line-range=:200 -- {}; else sed -n \"1,200p\" -- {}; fi; fi'"

export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS} --preview-window 'right,50%,border-left'"

export FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS} --bind 'ctrl-/:change-preview-window(down,20%,border-top|left,50%,border-right|up,20%,border-bottom|hidden|)'"

# Alt-C: preview directories and skip generated trees.
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'find {} -maxdepth 2 -print 2>/dev/null | head -100'
  --preview-window 'right,50%,border-left'
"
# Ctrl+R: busca no histórico do bash
export FZF_CTRL_R_OPTS="
  --height=20%
  --layout=reverse
  --style=minimal
  --border=rounded
  --margin=1
  --padding=1
  --info=right
  --border-label=' Command history '
  --prompt ' '
  --pointer '▶'
  --marker '✓'
  --separator '─'
  --scrollbar '│'
  --no-sort
"

# Use find because it is available in the base system. Ignore Git metadata.
export FZF_DEFAULT_COMMAND='find -L . -mindepth 1 -path "*/.git" -prune -o -print 2>/dev/null'

# Base layout/style (cores vêm do tema)
export FZF_DEFAULT_OPTS="
    --height=40%
    --layout=reverse
    --style=full
    --border=rounded
    --margin=1
    --padding=1
    --info=right
    --border-label=' FZF '
    --input-label=' Search '
    --list-label=' Results '
    --prompt ' '
    --pointer '▶'
    --marker '✓'
    --separator '─'
    --scrollbar '│'
"

# Load fzf theme.
FZF_THEME_DIR="$HOME/.config/fzf/themes"
if [[ -r "$FZF_THEME_DIR/${FZF_THEME:-}.theme.bashrc" ]]; then
  source "$FZF_THEME_DIR/${FZF_THEME:-}.theme.bashrc"
fi
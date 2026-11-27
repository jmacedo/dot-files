# Keymapping Cheatsheet

## Operational System: Pop OS
- [CMD]: Open system launcher
- [CMD+[0-9]]: Go to workspace (N)
- [CMD+b]: Open browser
- [CMD+c]: Open code editor
- [CMD+e]: Open text editor
- [CMD+f]: Open file explorer
- [CMD+m]: Maximize current window
- [CMD+q|Alt+F4]: Close current window
- [CMD+t]: Open terminal
- [CMD+Esc]: Block screen
- [CMD+a]: Open all apps menu
- [CMD+[Left|Right|Up|Down]]: Move focus between windows/Switch workspace
- [CMD+Shift+[Left|Right|Up|Down]]: Move tiled window/Change window workspace
- [CTRL+Shift+Down]: Minimize current window
- [CMD+Alt+[Left|Right]]: Switch monitor focus
- [CMD+Alt+Shift+[Left|Right]]: Move current window to next monitor
- [CMD+CTRL+Shift+[Up|Down]]: Move current window to next workspace
- [Alt+Tab]: Switch between opened visual applications

## General in app shortcuts
- [CTRL+a]: Select all
- [CTRL+c]: Copy
- [CTRL+f]: Find
- [CTRL+n]: New
- [CTRL+o]: Open
- [CTRL+p]: Print
- [CTRL+q|CTRL+w]: Close
- [CTRL+r]: Run/Redo last action
- [CTRL+s]: Save
- [CTRL+v]: Paste
- [CTRL+x]: Cut
- [CTRL+z]: Undo last action
- [CTRL+[PageUp|PageDown]]: Tabs navigation

### General text editors
- [CTRL+Alt+[PageUp|PageDown]]: Tabs navigation
- [CTRL+h]: Find and replace text
- [Home] button tricks:
    - [Home]: Move cursor to line begins
    - [CTRL+Home]: Move cursor to the document begins
    - [Shift+Home]: Select text from the cursor to the begin of the line
    - [CTRL+Shift+Home]: Select text from the cursor to the begin of the document
- [End] button tricks:
    - [End]: Move cursor to line ends
    - [CTRL+End]: Move cursor to the document ends
    - [Shift+End]: Select text from the cursor to the end of the line
    - [CTRL+Shift+End]: Select text from the cursor to the end of the document
- Entire word handling:
    - [CTRL+Delete|CTRL+Backspace]: Delete entire word
    - [CTRL+[Left|Right]]: Move cursor between words
    - [CTRL+Shift+[Left|Right]]: Select text word by word to the arrow direction

### General web navigators
- [CTRL+t]: Open new tab
- [CTRL+Shift+[PageUp|PageDown]]: Move current tab
- [CTRL+Shift[n|p]]: Open private window

## Terminal app: Kitty
- [CTRL+Shift+c]: Copy
- [CTRL+Shift+v]: Paste
- Tabs:
    - [CTRL+n]: Open new tab
    - [CTRL+q]: Close current tab
    - [CTRL+[PageUp|PageDown]]: Navigate between tabs
    - [CTRL+Shift+[PageUp|PageDown]]: Move current tab [Backward|Forward]
    - [CTRL+Shift+r]: Rename current tab
- Panels:
    - [CTRL+Alt+h]: Create a side panel (horizontally)
    - [CTRL+Alt+v]: Create a bottom panel (vertically)
    - [CTRL+Alt+q]: Close current panel
    - [CTRL+Alt+[Arrows]]: Navigate between panels (change focus)
    - [CTRL+Alt+Shift+[Arrows]]: Move panels
    - [CTRL+Alt+[h|l]]: Resize panel horizontally
    - [CTRL+Alt+[j|k]]: Resize panel vertically

## IDE: NeoVim
- Settings:
    - [Leader+r]: Reload configurations
    - [Leader+pp]: Plugin manager
    - [Leader+pm]: Mason manager
- Documents:
    - [CTRL+s]: Save
    - [CTRL+Shift+s]: Save and quit
    - [CTRL+w]: Quit
    - [CTRL+Shift+w]: Quit without saving
    - [CTRL+a]: Select all text
    - [CTRL+p]: Select word text
    - [CTRL+Shift+a]: Select all context text
- Tabs:
    - Preffix: [Leader+t]
    - [Preffix+n]: Open new tab
    - [Preffix+q]: Close current tab
    - [CTRL+CMD+[PageUp|PageDown]]: Navigate between tabs
    - [CTRL+CMD+Shift[PageUp|PageDown]]: Move tabs
    - [CTRL+CMD+[1-9]]|[Preffix+[1-9]]: Select the N(th) tab
- Tools/Helpers:
    - [Leader+e|CTRL+e]: File explorer
    - [Leader+z]: Toggle code folding
    - [Leader+Z]: Toggle all code foldings
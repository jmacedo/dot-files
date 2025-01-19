#!/bin/bash

WELCOME_STRING="\n#============================================================"\
"\n# Author: José Macedo"\
"\n# Creation:19/01/2025"\
"\n# Last Modify: 19/01/2025"\
"\n# From this point on, the settings are made by the user."\
"\n#============================================================\n";

WELCOME_ALIASES_STRING="\n#============================================================"\
"\n# ALIASES"\
"\n#============================================================\n";

ALIASES=`cat aliases.jm`;

# BASH
echo -e "\n$WELCOME_STRING$WELCOME_ALIAS_STRING\n$ALIASES\n" >> ~/.bashrc;

#ZSH
echo -e "\n$WELCOME_STRING$WELCOME_ALIAS_STRING\n$ALIASES\n" >> ~/.zshrc;
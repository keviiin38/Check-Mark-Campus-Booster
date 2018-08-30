#!/bin/bash


##############################################################################
#    Check-Mark-Campus-Booster - Get notified when a new mark is available   #
#    Copyright (C) 2018 Kevin Delbegue                                       #
#                                                                            #
#    This program is free software: you can redistribute it and/or modify    #
#    it under the terms of the GNU General Public License as published by    #
#    the Free Software Foundation, either version 3 of the License, or       #
#    any later version.                                                      #
#                                                                            #
#    This program is distributed in the hope that it will be useful,         #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#    GNU General Public License for more details.                            #
#                                                                            #
#    You should have received a copy of the GNU General Public License       #
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.   #
##############################################################################


# Check existing "check-mark-campus-booster-venv" folder
echo -en "[    ] python3 virtualenv\r"; sleep 0.5
if [ -e ../check-mark-campus-booster-venv ]; then
    echo -en "\e[32m[ OK ]\e[0m python3 virtualenv\n"; sleep 0.5
else
    echo -en "\e[31m[ OK ]\e[0m python3 virtualenv\n"; sleep 0.5
    echo "Please run the INSTALL.sh script first"
    exit 1
fi

# Install discord module with pip
echo -en "[    ] discord install\r"; sleep 0.5
../check-mark-campus-booster-venv/bin/pip install discord --quiet
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m discord install\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m discord install\n"; sleep 0.5
    exit 1
fi

# All requirements installed
echo -en "\n\e[32m[ OK ] All requirements installed !\e[0m\n\n"; sleep 0.5

# Get the Discord Token for the Bot
read -p "Discord Bot Token : " DISCORD_BOT_TOKEN

# Replace the Discord Bot Token in the script
sed -i "s/TOKEN =.*/TOKEN = \"$DISCORD_BOT_TOKEN\"/" discord_bot.py

# Unset the Discord Bot Token
unset DISCORD_BOT_TOKEN

# Install finished
echo -en "\n\e[32m[ OK ] Install finished !\e[0m\n"; sleep 0.5
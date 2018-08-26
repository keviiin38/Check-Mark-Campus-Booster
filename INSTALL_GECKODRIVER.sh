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


# Check if script is run as root
echo -en "[    ] root privileges\r"; sleep 1
if [[ $EUID -ne 0 ]]; then
    echo -en "\e[31m[FAIL]\e[0m root privileges\n"; sleep 1
   echo "This script must be run as root"
   exit 1
else
    echo -en "\e[32m[ OK ]\e[0m root privileges\n"; sleep 1
fi

cd /tmp

# Remove existing geckodriver files
if [ -e /tmp/geckodriver ]; then
    rm geckodriver
fi
if [ -e /tmp/geckodriver-linux64.tar.gz ]; then
    rm geckodriver-linux64.tar.gz
fi

# Download geckodriver from Github
echo -en "[    ] geckodriver downloaded\r"; sleep 1
wget --quiet https://github.com$(curl -sL https://github.com/mozilla/geckodriver/releases/latest | grep 'linux64' | head -1 | cut -d '"' -f 2) -O geckodriver-linux64.tar.gz
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m geckodriver downloaded\n"; sleep 1
else
    echo -en "\e[31m[FAIL]\e[0m geckodriver downloaded\n"; sleep 1
    exit 1
fi

# Extract geckodriver
echo -en "[    ] geckodriver extracted\r"; sleep 1
tar -zxvf geckodriver-linux64.tar.gz &> /dev/null
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m geckodriver extracted\n"; sleep 1
else
    echo -en "\e[31m[FAIL]\e[0m geckodriver extracted\n"; sleep 1
    exit 1
fi

# Move geckodriver to /usr/bin
echo -en "[    ] geckodriver moved to /usr/bin\r"; sleep 1
mv geckodriver /usr/bin/geckodriver
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m geckodriver moved to /usr/bin\n"; sleep 1
else
    echo -en "\e[31m[FAIL]\e[0m geckodriver moved to /usr/bin\n"; sleep 1
    exit 1
fi

# Remove downloaded files
rm geckodriver-linux64.tar.gz
cd - &> /dev/null

# Install finished
echo -en "[    ] geckodriver installed successfully !\r"; sleep 1
echo -en "\e[32m[ OK ]\e[0m geckodriver installed successfully !\n"; sleep 1


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

# Check if curl is installed
echo -en "[    ] curl installed\r"; sleep 0.5
if command -v curl &> /dev/null; then
    echo -en "\e[32m[ OK ]\e[0m curl installed\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m curl installed\n"; sleep 0.5
    echo "Please install curl"
    exit 1
fi

# Check if wget is installed
echo -en "[    ] wget installed\r"; sleep 0.5
if command -v wget &> /dev/null; then
    echo -en "\e[32m[ OK ]\e[0m wget installed\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m wget installed\n"; sleep 0.5
    echo "Please install wget"
    exit 1
fi

cd /tmp

# Remove existing chromedriver files
if [ -e /tmp/chromedriver ]; then
    rm chromedriver
fi
if [ -e /tmp/chromedriver_linux64.zip ]; then
    rm chromedriver_linux64.zip
fi

# Download chromediver
echo -en "[    ] chromedriver downloaded\r"; sleep 1
wget --quiet "https://chromedriver.storage.googleapis.com/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip"
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m chromedriver downloaded\n"; sleep 1
else
    echo -en "\e[31m[FAIL]\e[0m chromedriver downloaded\n"; sleep 1
    exit 1
fi

# Extract chromedriver
echo -en "[    ] chromedriver extracted\r"; sleep 1
unzip chromedriver_linux64.zip &> /dev/null
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m chromedriver extracted\n"; sleep 1
else
    echo -en "\e[31m[FAIL]\e[0m chromedriver extracted\n"; sleep 1
    exit 1
fi

# Move chromedriver to /usr/bin
echo -en "[    ] chromedriver moved to /usr/bin\r"; sleep 1
mv chromedriver /usr/bin/chromedriver
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m chromedriver moved to /usr/bin\n"; sleep 1
else
    echo -en "\e[31m[FAIL]\e[0m chromedriver moved to /usr/bin\n"; sleep 1
    exit 1
fi

# Remove downloaded files
rm chromedriver_linux64.zip
cd - &> /dev/null

# Install finished
echo -en "[    ] chromedriver installed successfully !\r"; sleep 1
echo -en "\e[32m[ OK ]\e[0m chromedriver installed successfully !\n"; sleep 1


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


read -p "Which browser would you use ? (Firefox/Chromium/Chrome) : " BROWSER
case "$BROWSER" in
    [fF][iI][rR][eE][fF][oO][xX]) BROWSER="firefox"; echo ;;
    [cC][hH][rR][oO][mM][eE]) BROWSER="chrome"; echo ;;
    [cC][hH][rR][oO][mM][iI][uU][mM]) BROWSER="chromium"; echo ;;
    *) exit 1;;
esac

# Check if python3 is installed
echo -en "[    ] python3 install\r"; sleep 0.5
if command -v python3 &> /dev/null; then
    echo -en "\e[32m[ OK ]\e[0m python3 install\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m python3 install\n"; sleep 0.5
    echo "Please install python3"
    exit 1
fi

# Check if python3-pip is installed
echo -en "[    ] python3-pip install\r"; sleep 0.5
if dpkg -s python3-pip &> /dev/null; then
    echo -en "\e[32m[ OK ]\e[0m python3-pip install\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m python3-pip install\n"; sleep 0.5
    echo "Please install python3-pip"
    exit 1
fi

# Check if python3-venv is installed
echo -en "[    ] python3-venv install\r"; sleep 0.5
if dpkg -s python3-venv &> /dev/null; then
    echo -en "\e[32m[ OK ]\e[0m python3-venv install\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m python3-venv install\n"; sleep 0.5
    echo "Please install python3-venv"
    exit 1
fi

# Create python3 virtual environment
echo -en "[    ] python3 virtualenv creation\r"; sleep 0.5
python3 -m venv ./check-mark-campus-booster-venv
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m python3 virtualenv creation\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m python3 virtualenv creation\n"; sleep 0.5
    exit 1
fi

# Install beautifulsoup4 module with pip
echo -en "[    ] beautifulsoup4 install\r"; sleep 0.5
./check-mark-campus-booster-venv/bin/pip install beautifulsoup4 --quiet
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m beautifulsoup4 install\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m beautifulsoup4 install\n"; sleep 0.5
    exit 1
fi

# Install selenium module with pip
echo -en "[    ] selenium install\r"; sleep 0.5
./check-mark-campus-booster-venv/bin/pip install selenium --quiet
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m selenium install\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m selenium install\n"; sleep 0.5
    exit 1
fi

# Check if the $BROWSER is installed
echo -en "[    ] $BROWSER install\r"; sleep 0.5
case "$BROWSER" in
    firefox)
        if ! [ -e /usr/bin/firefox -o -e /usr/local/bin/firefox ]; then
            echo -en "\e[31m[FAIL]\e[0m $BROWSER install\n"; sleep 0.5
            echo "Please install firefox to /usr/bin or /usr/local/bin"
            exit 1
        else
            echo -en "\e[32m[ OK ]\e[0m $BROWSER install\n"; sleep 0.5
        fi ;;
    chromium)
        if ! [ -e /usr/bin/chromium-browser -o -e /usr/local/bin/chromium-browser ]; then
            echo -en "\e[31m[FAIL]\e[0m $BROWSER install\n"; sleep 0.5
            echo "Please install chromium-browser to /usr/bin or /usr/local/bin"
            exit 1
        else
            echo -en "\e[32m[ OK ]\e[0m $BROWSER install\n"; sleep 0.5
        fi ;;
    chrome)
        if ! [ -e /usr/bin/google-chrome-stable -o -e /usr/local/bin/google-chrome-stable ]; then
            echo -en "\e[31m[FAIL]\e[0m $BROWSER install\n"; sleep 0.5
            echo "Please install google-chrome-stable to /usr/bin or /usr/local/bin"
            exit 1
        else
            echo -en "\e[32m[ OK ]\e[0m $BROWSER install\n"; sleep 0.5
        fi ;;
    *) exit 1 ;;
esac

case "$BROWSER" in
    firefox)
        echo -en "[    ] geckodriver install\r"; sleep 0.5
        if ! [ -e /usr/bin/geckodriver -o -e /usr/local/bin/geckodriver ]; then
            echo -en "\e[31m[FAIL]\e[0m geckodriver install\n"; sleep 0.5
            echo "Please run ./INSTALL_GECKODRIVER.sh"
            exit 1
         else
            echo -en "\e[32m[ OK ]\e[0m geckodriver install\n"; sleep 0.5
        fi ;;
    chrome | chromium)
        echo -en "[    ] chromedriver install\r"; sleep 0.5
        if ! [ -e /usr/bin/chromedriver -o -e /usr/local/bin/chromedriver ]; then
            echo -en "\e[31m[FAIL]\e[0m chromedriver install\n"; sleep 0.5
            echo "Please run ./INSTALL_CHROMEDRIVER.sh"
            exit 1
        else
            echo -en "\e[32m[ OK ]\e[0m chromedriver install\n"; sleep 0.5
        fi ;;
    *) exit 1 ;;
esac

# All requirements installed
echo -en "\n\e[32m[ OK ] All requirements installed !\e[0m\n\n"; sleep 0.5

# Get all information for the python script
read -p "ID Booster               : " IDBOOSTER
read -s -p "Campus Booster password  : " SUPINFO_PASSWORD
echo ''
read -p "GMail address            : " GMAIL_ADDRESS
read -s -p "GMail password           : " GMAIL_PASSWORD
echo ''
read -p "Receiver address         : " RECEIVER_ADDRESS

# Replace all information in the python script
sed -i "s/IDBOOSTER =.*/IDBOOSTER = \"$IDBOOSTER\"/" check_mark_campus_booster.py
sed -i "s/SUPINFO_PASSWORD =.*/SUPINFO_PASSWORD = \"$SUPINFO_PASSWORD\"/" check_mark_campus_booster.py
sed -i "s/GMAIL_ADDRESS =.*/GMAIL_ADDRESS = \"$GMAIL_ADDRESS\"/" check_mark_campus_booster.py
sed -i "s/GMAIL_PASSWORD =.*/GMAIL_PASSWORD = \"$GMAIL_PASSWORD\"/" check_mark_campus_booster.py
sed -i "s/RECEIVER_ADDRESS =.*/RECEIVER_ADDRESS = \"$RECEIVER_ADDRESS\"/" check_mark_campus_booster.py
sed -i "s/BROWSER = \".*/BROWSER = \"$BROWSER\"/" check_mark_campus_booster.py

# Unset all used variables
unset PIP_VERSION IDBOOSTER SUPINFO_PASSWORD GMAIL_ADDRESS GMAIL_PASSWORD RECEIVER_ADDRESS BROWSER

# First run of the python script
echo
echo -en "[    ] check_mark_campus_booster.py first run\r"; sleep 0.5
./check_mark_campus_booster.py
if [ $? -eq 0 ]; then
    echo -en "\e[32m[ OK ]\e[0m check_mark_campus_booster.py first run\n"; sleep 0.5
else
    echo -en "\e[31m[FAIL]\e[0m check_mark_campus_booster.py first run\n"; sleep 0.5
    exit 1
fi

# Install finished
echo -en "\n\e[32m[ OK ] Install finished !\n"; sleep 0.5
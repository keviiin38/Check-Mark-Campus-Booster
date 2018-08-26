#!/bin/bash

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

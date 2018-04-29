#!/bin/bash

if ( ! dpkg -s python-pip &> /dev/null ); then
  echo "Please install python-pip"
  read -p "Would you like to run the install now (You'll be prompted for the root password) ? (Yes/No) : " answer
  case "$answer" in
    [yY] | [yY][eE][sS]) su -c "apt-get install python-pip -y &> /dev/null && echo -e \"python-pip installed !\n\"" root;;
    [nN] | [nN][oO]) exit 1 ;;
    *) exit 1;;
  esac
  unset answer
fi

if ( ! python3 -c "import bs4" &> /dev/null); then
  echo "Please install Python module BeautifulSoup4"
  read -p "Would you like to run the install now ? (Yes/No) : " answer
  case "$answer" in
    [yY] | [yY][eE][sS]) pip install --user beautifulsoup4 &> /dev/null && echo -e "beautifulsoup4 installed !\n" ;;
    [nN] | [nN][oO]) exit 1 ;;
    *) exit 1;;
  esac
  unset answer
fi

if ( ! python3 -c "import selenium" &> /dev/null); then
  echo "Please install Python module selenium"
  read -p "Would you like to run the install now ? (Yes/No) : " answer
  case "$answer" in
    [yY] | [yY][eE][sS]) pip install --user selenium &> /dev/null && echo -e "selenium installed !\n" ;;
    [nN] | [nN][oO]) exit 1 ;;
    *) exit 1;;
  esac
  unset answer
fi

if ! [ -e /usr/bin/firefox -o -e /usr/local/bin/firefox ]; then
  echo "Please install firefox"
  read -p "Would you like to run the install now (You'll be prompted for the root password) ? (Yes/No) : " answer
    case "$answer" in
    [yY] | [yY][eE][sS]) su -c "apt-get install firefox -y &> /dev/null && echo -e \"firefox installed !\n\"" root ;;
    [nN] | [nN][oO]) exit 1 ;;
    *) exit 1;;
  esac
  unset answer
fi

if ! [ -e /usr/bin/geckodriver -o -e /usr/local/bin/geckodriver ]; then
  echo "Please install geckodriver"
  read -p "Would you like to run the install now (You'll be prompted for the root password) ? (Yes/No) : " answer
  case "$answer" in
    [yY] | [yY][eE][sS])
        cd /tmp
        wget https://github.com/mozilla/geckodriver/releases/download/v0.20.1/geckodriver-v0.20.1-linux64.tar.gz &> /dev/null
        tar -zxvf geckodriver-v0.20.1-linux64.tar.gz &> /dev/null
        su -c "mv geckodriver /usr/bin/geckodriver" root
        rm geckodriver-v0.20.1-linux64.tar.gz
        echo -e "geckodriver installed !\n"
        ;;
    [nN] | [nN][oO]) exit 1 ;;
    *) exit 1;;
  esac
fi

echo -e "All requirements installed !\n"

read -p "ID Booster : " IDBOOSTER
read -p "Campus Booster password : " SUPINFO_PASSWORD
read -p "GMail address : " GMAIL_ADDRESS
read -p "GMail password : " GMAIL_PASSWORD
read -p "Receiver address : " RECEIVER_ADDRESS

sed -i "s/IDBOOSTER =.*/IDBOOSTER = \"$IDBOOSTER\"/" check_mark_campus_booster.py
sed -i "s/SUPINFO_PASSWORD =.*/SUPINFO_PASSWORD = \"$SUPINFO_PASSWORD\"/" check_mark_campus_booster.py
sed -i "s/GMAIL_ADDRESS =.*/GMAIL_ADDRESS = \"$GMAIL_ADDRESS\"/" check_mark_campus_booster.py
sed -i "s/GMAIL_PASSWORD =.*/GMAIL_PASSWORD = \"$GMAIL_PASSWORD\"/" check_mark_campus_booster.py
sed -i "s/RECEIVER_ADDRESS =.*/RECEIVER_ADDRESS = \"$RECEIVER_ADDRESS\"/" check_mark_campus_booster.py

IDBOOSTER+="_SUPINFO_MARKS"

cp IDBOOSTER_SUPINFO_MARKS $IDBOOSTER

unset IDBOOSTER SUPINFO_PASSWORD GMAIL_ADDRESS GMAIL_PASSWORD RECEIVER_ADDRESS

echo -e "\nInstall finished !"

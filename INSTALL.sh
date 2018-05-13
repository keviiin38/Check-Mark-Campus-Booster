#!/bin/bash

read -p "Which browser would you use ? (Firefox/Chromium/Chrome) : " BROWSER
case "$BROWSER" in
    [fF][iI][rR][eE][fF][oO][xX]) BROWSER="firefox"; echo ;;
    [cC][hH][rR][oO][mM][eE]) BROWSER="chrome"; echo ;;
    [cC][hH][rR][oO][mM][iI][uU][mM]) BROWSER="chromium"; echo ;;
    *) exit 1;;
esac

if ( ! dpkg -s python-pip &> /dev/null ); then
    echo "Please install python-pip"
    read -p "Would you like to run the install now (You'll be prompted for the root password) ? (Yes/No) : " answer
    case "$answer" in
        [yY] | [yY][eE][sS]) su -c "apt-get install python-pip -y && echo -e \"\npython-pip installed !\n\"" root;;
        [nN] | [nN][oO]) exit 1 ;;
        *) exit 1;;
    esac
    unset answer
fi

if ( ! python3 -c "import bs4" &> /dev/null); then
    echo "Please install Python module BeautifulSoup4"
    read -p "Would you like to run the install now ? (Yes/No) : " answer
    case "$answer" in
        [yY] | [yY][eE][sS]) pip install --user beautifulsoup4 && echo -e "\nbeautifulsoup4 installed !\n" ;;
        [nN] | [nN][oO]) exit 1 ;;
        *) exit 1;;
    esac
    unset answer
fi

if ( ! python3 -c "import selenium" &> /dev/null); then
    echo "Please install Python module selenium"
    read -p "Would you like to run the install now ? (Yes/No) : " answer
    case "$answer" in
        [yY] | [yY][eE][sS]) pip install --user selenium && echo -e "\nselenium installed !\n" ;;
        [nN] | [nN][oO]) exit 1 ;;
        *) exit 1;;
    esac
    unset answer
fi

case "$BROWSER" in
    firefox)
        if ! [ -e /usr/bin/firefox -o -e /usr/local/bin/firefox ]; then
            echo "Please install firefox"
            read -p "Would you like to run the install now (You'll be prompted for the root password) ? (Yes/No) : " answer
            case "$answer" in
                [yY] | [yY][eE][sS]) su -c "apt-get install firefox -y && echo -e \"\nfirefox installed !\n\"" root ;;
                [nN] | [nN][oO]) exit 1 ;;
                *) exit 1;;
            esac
            unset answer
        fi ;;
    chromium)
        if ! [ -e /usr/bin/chromium-browser -o -e /usr/local/bin/chromium-browser ]; then
            echo "Please install chromium-browser"
            read -p "Would you like to run the install now (You'll be prompted for the root password) ? (Yes/No) : " answer
                case "$answer" in
                [yY] | [yY][eE][sS]) su -c "apt-get install chromium-browser -y && echo -e \"\nchromium-browser installed !\n\"" root ;;
                [nN] | [nN][oO]) exit 1 ;;
                *) exit 1;;
            esac
            unset answer
        fi ;;
    chrome)
        if ! [ -e /usr/bin/google-chrome-stable -o -e /usr/local/bin/google-chrome-stable ]; then
            echo "Please install google-chrome-stable"
            read -p "Would you like to run the install now (You'll be prompted for the root password) ? (Yes/No) : " answer
                case "$answer" in
                [yY] | [yY][eE][sS])
                    cd /tmp
                    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
                    echo
                    su -c "apt-get install /tmp/google-chrome-stable_current_amd64.deb -y &> /dev/null" root
                    rm google-chrome-stable_current_amd64.deb
                    echo -e "\ngoogle-chrome-stable installed !\n"
                    cd - &> /dev/null ;;
                [nN] | [nN][oO]) exit 1 ;;
                *) exit 1;;
            esac
            unset answer
    fi ;;
    *) exit 1 ;;
esac

case "$BROWSER" in
    firefox)
        if ! [ -e /usr/bin/geckodriver -o -e /usr/local/bin/geckodriver ]; then
            echo "Please install geckodriver"
            read -p "Would you like to run the install now (You'll be prompted for the root password) ? (Yes/No) : " answer
            case "$answer" in
                [yY] | [yY][eE][sS])
                    cd /tmp
                    wget https://github.com/mozilla/geckodriver/releases/download/v0.20.1/geckodriver-v0.20.1-linux64.tar.gz
                    tar -zxvf geckodriver-v0.20.1-linux64.tar.gz &> /dev/null
                    echo
                    su -c "mv geckodriver /usr/bin/geckodriver" root
                    rm geckodriver-v0.20.1-linux64.tar.gz
                    echo -e "\ngeckodriver installed !\n"
                    cd - &> /dev/null ;;
                [nN] | [nN][oO]) exit 1 ;;
                *) exit 1 ;;
            esac
        fi ;;
    chrome | chromium)
        if ! [ -e /usr/bin/chromedriver -o -e /usr/local/bin/chromedriver ]; then
            echo "Please install chromedriver"
            read -p "Would you like to run the install now (You'll be prompted for the root password) ? (Yes/No) : " answer
            case "$answer" in
                [yY] | [yY][eE][sS])
                    cd /tmp
                    if [ -e /tmp/chromedriver ]; then
                        rm chromedriver
                    fi
                    if [ -e /tmp/chromedriver_linux64.zip ]; then
                        rm chromedriver_linux64.zip
                    fi
                    echo
                    wget https://chromedriver.storage.googleapis.com/2.38/chromedriver_linux64.zip
                    echo
                    unzip chromedriver_linux64.zip &> /dev/null
                    su -c "mv chromedriver /usr/bin/chromedriver" root
                    if [ $? -eq 1 ]; then
                        rm chromedriver_linux64.zip
                        exit 1
                    fi
                    rm chromedriver_linux64.zip
                    echo -e "\nchromedriver installed !\n"
                    cd - &> /dev/null ;;
                [nN] | [nN][oO]) exit 1 ;;
                *) exit 1;;
            esac
        fi ;;
    *) exit 1 ;;
esac


echo -e "All requirements installed !\n"

read -p "ID Booster : " IDBOOSTER
read -s -p "Campus Booster password : " SUPINFO_PASSWORD
echo ''
read -p "GMail address : " GMAIL_ADDRESS
read -s -p "GMail password : " GMAIL_PASSWORD
echo ''
read -p "Receiver address : " RECEIVER_ADDRESS

sed -i "s/IDBOOSTER =.*/IDBOOSTER = \"$IDBOOSTER\"/" check_mark_campus_booster.py
sed -i "s/SUPINFO_PASSWORD =.*/SUPINFO_PASSWORD = \"$SUPINFO_PASSWORD\"/" check_mark_campus_booster.py
sed -i "s/GMAIL_ADDRESS =.*/GMAIL_ADDRESS = \"$GMAIL_ADDRESS\"/" check_mark_campus_booster.py
sed -i "s/GMAIL_PASSWORD =.*/GMAIL_PASSWORD = \"$GMAIL_PASSWORD\"/" check_mark_campus_booster.py
sed -i "s/RECEIVER_ADDRESS =.*/RECEIVER_ADDRESS = \"$RECEIVER_ADDRESS\"/" check_mark_campus_booster.py
sed -i "s/BROWSER = \".*/BROWSER = \"$BROWSER\"/" check_mark_campus_booster.py

IDBOOSTER+="_SUPINFO_MARKS"

cp IDBOOSTER_SUPINFO_MARKS $IDBOOSTER

unset IDBOOSTER SUPINFO_PASSWORD GMAIL_ADDRESS GMAIL_PASSWORD RECEIVER_ADDRESS BROWSER

echo -e "\nInstall finished !"

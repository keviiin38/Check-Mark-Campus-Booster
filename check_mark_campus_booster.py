#!/usr/bin/python3

import pickle
import smtplib
import time
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from bs4 import BeautifulSoup
from selenium import webdriver

IDBOOSTER = ""
SUPINFO_PASSWORD = ""
GMAIL_ADDRESS = ""
GMAIL_PASSWORD = ""
RECEIVER_ADDRESS = ""
BROWSER = ""

if "" in (IDBOOSTER, SUPINFO_PASSWORD, GMAIL_ADDRESS, GMAIL_PASSWORD, RECEIVER_ADDRESS, BROWSER):
    print("Please run INSTALL.sh first !")
    exit(1)


def get_soup():
    if BROWSER == "firefox":
        options = webdriver.FirefoxOptions()
        options.add_argument("--headless")
        browser = webdriver.Firefox(firefox_options=options)
    elif BROWSER in ("chrome", "chromium"):
        options = webdriver.ChromeOptions()
        options.add_argument("--headless")
        browser = webdriver.Chrome(chrome_options=options)

    browser.get("https://campus-booster.net/Booster/v2/Academic/Cursus.aspx")

    time.sleep(2)

    idbooster = browser.find_element_by_id("actor_login_university_openid1_openIdBox")
    idbooster.send_keys(IDBOOSTER)
    login_button = browser.find_element_by_id("actor_login_university_openid1_loginButton")
    login_button.click()

    time.sleep(2)

    password = browser.find_element_by_id("Password")
    password.send_keys(SUPINFO_PASSWORD)
    login_button = browser.find_element_by_id("LoginButton")
    login_button.click()

    time.sleep(2)

    browser.get("https://campus-booster.net/Booster/v2/Academic/Cursus.aspx#tab_cursus_174")

    time.sleep(2)

    soup = BeautifulSoup(browser.page_source, "html.parser")

    browser.quit()

    return soup


def get_mark_list(soup):
    name_list = []
    id_list = []

    for div in soup.find_all("div"):
        div_id = div.get("id")
        if div_id is not None:
            if "cursus_174_subject" in div_id:
                name_list.append(div_id.split("_")[3])
                id_list.append(div_id)

    text_id_list = []

    for i in id_list:
        text_id_list.append(soup.find("div", id=i).text.strip().replace("\n", ""))

    mark_list = []

    for i in range(len(name_list)):
        if text_id_list[i] == "No mark for the moment":
            mark_list.append("nothing")
        else:
            mark = []
            while len(text_id_list[i]):
                if "#" in text_id_list[i]:
                    index = text_id_list[i].index("#")
                else:
                    break

                mark.append(text_id_list[i][:index + 2])
                text_id_list[i] = text_id_list[i][index + 2:]

                number = 0
                while not text_id_list[i][number].isalpha():
                    if number == len(text_id_list[i]) - 1:
                        number += 1
                        break
                    else:
                        number += 1

                mark.append(text_id_list[i][:number])
                text_id_list[i] = text_id_list[i][number:]

            mark_list.append(mark)

    return mark_list, name_list


def format_mark_list(mark_list, name_list):
    for i in range(len(mark_list)):
        print("===", name_list[i], "===")
        if mark_list[i] == "nothing":
            print("No mark for the moment")
        else:
            for j in range(0, len(mark_list[i]), 2):
                print(mark_list[i][j] + " : " + mark_list[i][j + 1])
        print("============\n")


def check_new_mark(mark_list):
    file = open(IDBOOSTER + "_SUPINFO_MARKS", "rb")
    old_mark_list = pickle.load(file)
    file.close()
    if old_mark_list == mark_list:
        return False
    else:
        return True


def build_mail_body(mark_list, name_list):
    file = open(IDBOOSTER + "_SUPINFO_MARKS", "rb")
    old_mark_list = pickle.load(file)
    file.close()

    new = []

    for i in range(len(mark_list)):
        if mark_list[i] != old_mark_list[i]:
            for j in range(0, len(mark_list[i]), 2):
                if mark_list[i][j + 1] != old_mark_list[i][j + 1]:
                    new.append([name_list[i], mark_list[i][j], mark_list[i][j + 1]])

    body = "You have " + str(len(new)) + " new mark(s) on https://campus-booster.net\n\n"
    for i in new:
        body = body + str("A " + i[2] + " at the " + i[1] + " of " + i[0] + "\n")

    return body, len(new)


def send_mail(mark_list, name_list):
    body, number = build_mail_body(mark_list, name_list)
    msg = MIMEMultipart()
    msg['From'] = GMAIL_ADDRESS
    msg['To'] = RECEIVER_ADDRESS
    msg['Subject'] = "[Mark - Check] " + str(number) + " mark(s) on Campus Booster !"

    msg.attach(MIMEText(body))

    mailserver = smtplib.SMTP('smtp.gmail.com', 587)
    mailserver.starttls()
    mailserver.login(GMAIL_ADDRESS, GMAIL_PASSWORD)
    mailserver.sendmail(GMAIL_ADDRESS, RECEIVER_ADDRESS, msg.as_string())
    mailserver.quit()


def main():
    soup = get_soup()
    mark_list, name_list = get_mark_list(soup)
    if check_new_mark(mark_list):
        print("New mark(s) !")
        send_mail(mark_list, name_list)
        print("Mail sent !")
        file = open(IDBOOSTER + "_SUPINFO_MARKS", "wb")
        pickle.dump(mark_list, file)
        file.close()
    else:
        print("Nothing new ...")


main()

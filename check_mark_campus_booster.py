#!check-mark-campus-booster-venv/bin/python3

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

import json
import os
import smtplib
import time
import urllib.error
import urllib.request
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from bs4 import BeautifulSoup
from selenium import webdriver

# Color for output
RESET_COLOR = "\033[0m"
BOLD = "\033[1m"
RED = "\033[31m"
GREEN = "\033[32m"

# Required information
IDBOOSTER = ""
SUPINFO_PASSWORD = ""
GMAIL_ADDRESS = ""
GMAIL_PASSWORD = ""
RECEIVER_ADDRESS = ""
BROWSER = ""

# Check for empty values in the required information
if "" in (IDBOOSTER, SUPINFO_PASSWORD, GMAIL_ADDRESS, GMAIL_PASSWORD, RECEIVER_ADDRESS, BROWSER):
    print("Please run " + BOLD + "./INSTALL.sh" + RESET_COLOR + " first !")
    exit(1)

# Check for internet connection
try:
    urllib.request.urlopen('https://1.1.1.1', timeout=1)
except urllib.error.URLError as err:
    print("This script requires an " + BOLD + "internet connection " + RESET_COLOR + "!")
    exit(1)


def init_browser():
    try:
        if BROWSER == "firefox":
            options = webdriver.FirefoxOptions()
            options.add_argument("--headless")
            return webdriver.Firefox(firefox_options=options)
        elif BROWSER in ("chrome", "chromium"):
            options = webdriver.ChromeOptions()
            options.add_argument("--headless")
            return webdriver.Chrome(chrome_options=options)
    except Exception as E:
        print(RED + "Error when initializing the browser...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def get_soup():
    try:
        # Initialize the web browser
        browser = init_browser()
        # Check for error at browser init
        if type(browser) is tuple and browser[0] == -1:
            return (-1, browser[1])

        # Go to SUPINFO's Campus-Booster web page
        browser.get("https://campus-booster.net")
        time.sleep(2)

        # Specify the IDBooster on the Campus-Booster home page
        idbooster = browser.find_element_by_id("actor_login_siu_sso_oauth2_openIdBox")
        idbooster.send_keys(IDBOOSTER)
        login_button = browser.find_element_by_id("actor_login_siu_sso_oauth2_loginButton")
        login_button.click()
        time.sleep(2)

        # Log in to SUPINFO's SSO
        password = browser.find_element_by_id("Password")
        password.send_keys(SUPINFO_PASSWORD)
        login_button = browser.find_element_by_name("button")
        login_button.click()
        time.sleep(2)

        # Check for login success or failure
        if browser.current_url.split("/")[2] == "sso.supinfo.com":
            raise Exception("Login to SUPINFO's SSO failed... Check the credentials and try again...")

        # Go to the Campus-Booster marks page
        browser.get("https://campus-booster.net/Booster/v2/Academic/Cursus.aspx#tab_cursus_174")
        time.sleep(2)

        # Get the soup from the web page
        soup = BeautifulSoup(browser.page_source, "html.parser")

        # Close the browser
        browser.quit()

        return soup

    except Exception as E:
        browser.quit()
        print(RED + "Error when getting the soup...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def get_subject_codes(soup):
    try:
        subject_codes = {}

        for div in soup.find_all("div"):
            div_id = div.get("id")

            # Get all subject codes (ex: xADS, xLIF, xKWS, xCNA, etc...)
            if div_id is not None and "cursus_174_subject" in div_id:
                subject_codes[div_id.split("_")[3]] = {}

        # Check for empty subject codes
        if subject_codes == {}:
            raise Exception("Empty subject codes...")

        return subject_codes

    except Exception as E:
        print(RED + "Error when getting the subject codes...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def get_subjects(soup):
    try:
        subjects = get_subject_codes(soup)
        # Check for error when getting the subject codes
        if type(subjects) is tuple and subjects[0] == -1:
            return (-1, subjects[1])

        for div in soup.find_all("div", class_="panel-heading"):
            # Get all information about each subject : name, code, ECTS and option
            info = div.text.strip().replace("\n", "").replace("  ", "").split("(")

            # Skip all items that aren't names, codes and ECTS credits
            if len(info) <= 1:
                continue

            # Remove all the ")", the " ", and the "#" from the info list
            info = [i.strip().replace(")", "").replace("#", "") for i in info]

            # Get only the number of ECTS credits
            info[-1] = info[-1][info[-1].find("-") + 1]

            # Set option to True or False if the subject is an option or not
            option = True if info[1] == "OPTION" else False

            # Add the name of the subject, the number of ECTS credits and the if it's an option to the dictionary
            subjects[info[-2]] = {"NAME": info[0], "ECTS": info[-1], "MARKS": {}, "OPTION": option}

        return subjects

    except Exception as E:
        print(RED + "Error when getting the subjects...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def get_marks(soup):
    try:
        subjects = get_subjects(soup)
        # Check for error when getting the subjects
        if type(subjects) is tuple and subjects[0] == -1:
            return (-1, subjects[1])

        for subject in subjects.keys():
            # Find all subjects and all marks with values and types for each
            for div in soup.find_all("div", id=("cursus_174_subject_" + subject)):
                if div.text.strip() == "No mark for the moment":
                    # Add None to the "MARKS" value if no mark for the moment
                    subjects[subject]["MARKS"] = None
                else:
                    marks = []
                    # Get all mark types and mark values
                    for span in div.find_all("span"):
                        marks.append(span.text.strip())

                    for i in range(0, len(marks), 2):
                        # Replace when no marks (" - ") by None value
                        marks[i + 1] = None if marks[i + 1] == "-" else marks[i + 1]

                        # Add the {"Mark type": Mark value} to the "MARKS" value of the subject
                        subjects[subject]["MARKS"].update({marks[i]: marks[i + 1]})

        return subjects

    except Exception as E:
        print(RED + "Error when getting the marks...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def format_marks_output(subjects):
    for subject in subjects.keys():
        print(subject + " :")
        print("  - Name   : " + subjects[subject]["NAME"])
        print("  - ECTS   : " + subjects[subject]["ECTS"])
        print("  - Marks  :")
        if subjects[subject]["MARKS"] is None:
            print("      - None")
        else:
            for mark_type, mark_value in subjects[subject]["MARKS"].items():
                print("      - " + mark_type + " : " + str(mark_value))
        print("  - Option : " + str(subjects[subject]["OPTION"]))
        print("")


def open_marks_file():
    try:
        # Open the IDBOOSTER_SUPINFO_MARKS.json file
        file = open(IDBOOSTER + "_SUPINFO_MARKS.json", "r")

        # Get all subjects and marks from the file
        subjects = json.load(file)

        file.close()
        return subjects

    except Exception as E:
        print(RED + "Error when reading from marks file...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def write_marks_file(subjects):
    try:
        # Open the IDBOOSTER_SUPINFO_MARKS.json file
        file = open(IDBOOSTER + "_SUPINFO_MARKS.json", "w")

        # Write all the subjects and marks from the subjects variable
        json.dump(subjects, file, indent=2)

        file.close()
        return True

    except Exception as E:
        print(RED + "Error when writing to marks file...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def check_new_marks(subjects):
    try:
        # Check if it's the first launch and the file IDBOOSTER_SUPINFO_MARKS.json doesn't exist
        if not os.path.isfile(IDBOOSTER + "_SUPINFO_MARKS.json"):
            return "FIRST"

        # Check if the file exist but is empty
        if os.path.getsize("./" + IDBOOSTER + "_SUPINFO_MARKS.json") <= 2:
            return "EMPTY"

        # If it's not the first launch, load the last IDBOOSTER_SUPINFO_MARKS.json file
        old_subjects = open_marks_file()

        # Return True if something changed else return False
        return True if old_subjects != subjects else False

    except Exception as E:
        print(RED + "Error when checking for new marks...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def compare_marks(subjects):
    try:
        # diff = [ [old], [new] ]
        # dif = [ [ [subject, old_mark_type, old_mark_value] ], [subject, new_mark_type, new_mark_value] ]
        diff = [[], []]
        changed = False
        old_subjects = open_marks_file()

        for subject in subjects.keys():
            # Simplify the notation of each dictionary
            old_subject = old_subjects[subject]
            new_subject = subjects[subject]
            old_marks = old_subject["MARKS"]
            new_marks = new_subject["MARKS"]

            # Check if the 2 dictionaries are identical or not
            if old_marks != new_marks:
                # New mark type and/or mark value added
                # OLD : {"MARKS": None} -> NEW : {"MARKS": {"MARK_TYPE": None} }
                # OLD : {"MARKS": None} -> NEW : {"MARKS": {"MARK_TYPE": mark_value} }
                if old_marks is None and new_marks is not None:
                    for mark_type, mark_value in new_marks.items():
                        # New mark added
                        if mark_value is not None:
                            diff[0].append([subject, None])
                            diff[1].append([subject, mark_type, mark_value])
                            changed = True

                        # New mark type
                        else:
                            diff[0].append([subject, None])
                            diff[1].append([subject, mark_type, None])

                # New mark added or mark value changed
                # OLD : {"MARKS": {"MARK_TYPE": None} } -> NEW : {"MARKS": {"MARK_TYPE": mark_value} }
                # OLD : {"MARKS": {"MARK_TYPE": mark_value} } -> NEW : {"MARKS": {"MARK_TYPE": new_mark_value} }
                else:
                    for mark_type, mark_value in new_marks.items():
                        # Simplify the notation of each dictionary
                        old_mark_value = old_marks[mark_type]
                        new_mark_value = mark_value

                        # New mark added
                        if old_mark_value is None and new_mark_value is not None:
                            diff[0].append([subject, mark_type, None])
                            diff[1].append([subject, mark_type, new_mark_value])
                            changed = True

                        # Mark changed
                        elif old_mark_value is not None and new_mark_value is not None:
                            if old_mark_value != mark_value:
                                diff[0].append([subject, mark_type, old_mark_value])
                                diff[1].append([subject, mark_type, new_mark_value])
                                changed = True

        # Check if something changed
        if not changed:
            print("Nothing changed !")
            return False
        else:
            return diff

    except Exception as E:
        print(RED + "Error when comparing marks...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def build_mail_body(diff, new_mark_values_count):
    # Plain text version of the body
    body_text = "The following marks were added to your Campus Booster :\n"
    for i in range(len(diff[1])):
        subject_code, mark_type, mark_value = diff[1][i][0], diff[1][i][1], diff[1][i][2]
        body_text += "\t- " + mark_value + " at the " + mark_type + " of " + subject_code + "\n"

    # HTML version of the body
    body_html = "<p>The following marks were added to your Campus Booster :</p><ul>"
    for i in range(len(diff[1])):
        subject_code, mark_type, mark_value = diff[1][i][0], diff[1][i][1], diff[1][i][2]
        body_html += "<li><strong> " + "<span style='color:" + ("green" if float(mark_value) >= 10 else "red") + "'>"
        body_html += mark_value + "</span></strong>"

        # Add the old mark if the mark's value changed
        if diff[0][i][2] is not None:
            body_html += " <em>(Old : <strong>" + "<span style='color:" + ("green" if float(diff[0][i][2]) >= 10 else "red")
            body_html += "'>" + diff[0][i][2] + "</span></strong>)</em>"

        body_html += " at the<strong> " + mark_type
        body_html += " </strong>of<strong> " + subject_code + " </strong></li>"
    body_html = "<html><head><body>" + body_html + "</ul></body></head></html>"

    # Subject of the mail
    subject = "[Mark - Check] " + str(new_mark_values_count) + " new mark(s) available !"

    return body_text, body_html, subject


def build_first_mail_body():
    # Plain text version of the body
    body_text = "This is the first launch of the check-campus-booster script.\n"
    body_text += "Your " + IDBOOSTER + "_SUPINFO_MARKS.json" + " file have been created with all your marks.\n"

    # HTML version of the body
    body_html = "<p>This is the first launch of the <em>check-mark-campus-booster</em> script.</p>"
    body_html += "<p>Your <em>" + IDBOOSTER + "_SUPINFO_MARKS.json</em>"
    body_html += " file have been created with all your marks.</p>"
    body_html = "<html><head><body>" + body_html + "</body></head></html>"

    # Subject of the mail
    subject = "[Mark - Check] First launch successful !"

    return body_text, body_html, subject


def build_error_mail_body(error):
    # Plain text version of the body
    body_text = "The check_mark_campus_booster script encountered the following error : \"" + error + "\""

    # HTML version of the body
    body_html = "The <em>check_mark_campus_booster</em> script encountered the following error : \""
    body_html += "<strong>" + error + "</strong>\""
    body_html = "<html><head><body>" + body_html + "</body></head></html>"

    # Subject of the mail
    subject = "[Error] The script encountered an error"

    return body_text, body_html, subject


def send_mail(diff=None, new_mark_values_count=None, error=None, first=False):
    try:
        # Get mail body (text and HTML) and mail subject
        if error is not None:
            body_text, body_html, subject = build_error_mail_body(error)
        elif first:
            body_text, body_html, subject = build_first_mail_body()
        else:
            body_text, body_html, subject = build_mail_body(diff, new_mark_values_count)

        msg = MIMEMultipart("alternative")

        # Add sender, receiver and subject to mail
        msg['From'] = "Check-Mark-Campus-Booster" + "<" + GMAIL_ADDRESS + ">"
        msg['To'] = RECEIVER_ADDRESS
        msg['Subject'] = subject

        # Attach the text body and HTML body to the mail
        msg.attach(MIMEText(body_text, 'plain'))
        msg.attach(MIMEText(body_html, 'html'))

        # Start the mail server
        mail_server = smtplib.SMTP('smtp.gmail.com', 587)
        mail_server.starttls()
        mail_server.login(GMAIL_ADDRESS, GMAIL_PASSWORD)
        mail_server.sendmail(GMAIL_ADDRESS, RECEIVER_ADDRESS, msg.as_string())

        # Stop the mail server
        mail_server.quit()
        return True

    except Exception as E:
        mail_server.quit()
        print(RED + "Error when sending mail...")
        print("Error information : " + RESET_COLOR + BOLD + str(E) + RESET_COLOR)
        return (-1, str(E))


def check_mark_campus_booster():
    # Get the soup
    soup = get_soup()
    # Check for error when getting soup
    if type(soup) is tuple and soup[0] == -1:
        # Send error mail
        send_mail(error=soup[1])
        exit(1)

    # Get the subjects
    subjects = get_marks(soup)
    # Check for error when getting the subjects
    if type(subjects) is tuple and subjects[0] == -1:
        send_mail(error=subjects[1])
        exit(1)

    # Check for new marks
    new_marks = check_new_marks(subjects)
    # Check for error when checking new marks
    if type(new_marks) is tuple and new_marks[0] == -1:
        send_mail(error=new_marks[1])
        exit(1)

    if new_marks == "FIRST":
        # Create the JSON file and write subjects and marks to it
        error = write_marks_file(subjects)

        # Check for error when writing to the JSON file
        if type(error) is tuple and error[0] == -1:
            # Send error mail
            send_mail(error=error[1])
            exit(1)
        else:
            send_mail(first=True)

    elif new_marks == "EMPTY":
        # Write to the JSON file because it's empty
        error = write_marks_file(subjects)

        # Check for error when writing to the JSON file
        if type(error) is tuple and error[0] == -1:
            # Send error mail
            send_mail(error=error[1])
            exit(1)

    elif new_marks:
        diff = compare_marks(subjects)
        # Check for error when comparing marks
        if type(diff) is tuple and diff[0] == -1:
            # Send error mail
            send_mail(error=diff[1])
            exit(1)

        # Count how many new marks were added
        new_mark_values_count = 0

        # Count how many new mark types were added
        new_mark_types_count = 0

        for i in range(len(diff[1])):
            if diff[1][i][2] is not None:
                new_mark_values_count += 1
            else:
                new_mark_types_count += 1

        mail_sent = send_mail(diff=diff, new_mark_values_count=new_mark_values_count)
        # Check for error when sending mail
        if type(mail_sent) is tuple and mail_sent[0] == -1:
            # Send error mail
            send_mail(error=mail_sent[1])
            exit(1)

        # Write to the JSON file the changes
        error = write_marks_file(subjects)

        # Check for error when writing to the JSON file
        if type(error) is tuple and error[0] == -1:
            # Send error mail
            send_mail(error=error[1])
            exit(1)

        print(new_mark_values_count, "new mark(s) !\nMail sent !")
    else:
        print("Nothing new...")


check_mark_campus_booster()

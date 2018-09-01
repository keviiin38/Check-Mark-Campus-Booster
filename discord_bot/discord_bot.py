#!../check-mark-campus-booster-venv/bin/python3


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


import check_mark_campus_booster_discord_bot as cm
import discord

TOKEN = ""

client = discord.Client()


def build_msg(message):
    # Start to check for new marks
    msg = cm.check_mark_campus_booster_discord_bot()

    # Notify if an error occurs
    if type(msg) is tuple and msg[1] == -1:
        msg = "Error : " + str(msg[1])
    elif msg:
        # Count new marks
        msg_tmp = str(len(msg)) + " new marks available !\n"

        # Add subject code and mark type
        for i in msg:
            msg_tmp += "\t - " + i[1] + " of " + i[0] + "\n"

        msg = msg_tmp
    else:
        # No new mark
        msg = "Nothing new..."

    # Add the author and mention him
    msg = message.author.mention + "\n" + msg

    return msg


@client.event
async def on_message(message):
    # We do not want the bot to reply to itself
    if message.author == client.user:
        return

    if message.content.upper().startswith('!HELLO'):
        msg = 'Hello {0.author.mention}'.format(message)
        await client.send_message(message.channel, msg)

    # Display the help message
    if message.content.upper().startswith("!HELP"):
        msg = "+-----------------------------------------------------------------+\n"
        msg += "|   Check-Mark-Campus-Booster Discord Bot  -  Help    |\n"
        msg += "+-----------------------------------------------------------------+\n\n"
        msg += "Coming soon...\n"
        await client.send_message(message.channel, msg)

    # Manually check for new marks
    if message.content.upper().startswith("!CHECK"):
        # Send a wait message
        msg = message.author.mention + ", I'll check now, please wait 30 sec for the result."
        await client.send_message(message.channel, msg)

        msg = build_msg(message)

        # Send the message with the result
        await client.send_message(message.channel, msg)


@client.event
async def on_ready():
    print("==== Logged in ====")
    print("Username : " + client.user.name)
    print("UserID : " + client.user.id)
    print("===================\n")

    # Send a message to each channel of each server where the bot is connected to
    for server in client.servers:
        for channel in server.channels:
            try:
                # Send message to Text Channels only
                if channel.type.value == 0:
                    msg = "+---------------------------------------------------+\n"
                    msg += "|                        I'm now **available** !                        |\n"
                    msg += "+---------------------------------------------------+\n"
                    msg += "|   _If you want some help, just type \"**!help**\"._   |\n"
                    msg += "+---------------------------------------------------+\n"
                    await client.send_message(channel, msg)
            except AttributeError:
                pass


client.run(TOKEN)

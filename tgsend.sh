#!/bin/bash
#########################################################
# send message to your own Telegram Bot API 
# using BotFather 
# https://core.telegram.org/bots#3-how-do-i-create-a-bot
# https://core.telegram.org/bots/api#sendmessage
#
# requires jq json tool install:
#
# apt-get -y install jq
# yum -y install jq
#
#########################################################
# create and populate tgtoken.ini file in same
# directory as tgsend.sh with the following:
#
# tgtoken='YOUR_TELEGRAM_BOT_API_TOKEN'
# tgchatid='YOUR_TELEGRAM_CHATID'
# tgapi="https://api.telegram.org/bot$tgtoken"
#########################################################
tg_notifications='y'
#########################################################
. tgtoken.ini

tg_send() {
  format=$1
  message="$2"
  silent="$3"

  if [[ "$format" = 'md' ]]; then
    format_opt=' -d parse_mode=MarkdownV2'
  elif [[ "$format" = 'html' ]]; then
    format_opt=' -d parse_mode=HTML'
  else
    format_opt=
  fi
  if [[ "tg_notifications" = [nN] || "$silent" = 'quiet' ]]; then
    notify_opt=' -d disable_notification=true'
  else
    notify_opt=' -d disable_notification=false'
  fi

  curl -4s -X POST "$tgapi/sendMessage"${notify_opt}${format_opt} -d chat_id="$tgchatid" -d text="$message" |  jq -r '.result | {from: .from.first_name, to: .chat.first_name, date: .date | todate, message: .text }'
}

help() {
  echo
  echo "Usage:"
  echo
  echo "$0 send \"your message in double quotes\""
  # echo "$0 sendmd \"your message in double quotes\""
  echo "$0 sendhtml \"your message in double quotes\""
  echo
  echo "disable notifications:"
  echo
  echo "$0 sendq \"your message in double quotes\""
  # echo "$0 sendmdq \"your message in double quotes\""
  echo "$0 sendhtmlq \"your message in double quotes\""
}

case "$1" in
  send )
    tg_send txt "$2"
    ;;
  sendmd )
    tg_send md "$2"
    ;;
  sendhtml )
    tg_send html "$2"
    ;;
  sendq )
    tg_send txt "$2" quiet
    ;;
  sendmdq )
    tg_send md "$2" quiet
    ;;
  sendhtmlq )
    tg_send html "$2" quiet
    ;;
  * )
    help
    ;;
esac
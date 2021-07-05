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
#
# if you don't know your Telegram chat id, you can leave
# it empty and script will derive the chat id from the
# Telegram API via your Bot API token credentials
#########################################################
tg_notifications='y'
#########################################################
. tgtoken.ini

if [ -z "$tgchatid" ]; then
  tgchatid=$(curl -4s $tgapi/getUpdates | jq -r '.result[].message.chat.id')
fi

tg_send() {
  format=$1
  message="$2"
  silent="$3"
  tg_type='sendMessage'

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

  curl -4s -X POST "$tgapi/${tg_type}"${notify_opt}${format_opt} -d chat_id="$tgchatid" -d text="$message" |  jq -r '.result | {from: .from.first_name, to: .chat.first_name, date: .date | todate, message: .text }'
}

tg_sendf() {
  format=$1
  file="$2"
  silent="$3"
  tg_type='sendDocument'

  if [[ "$format" = 'file' && -f "$file" ]]; then
    file="$file"
    if [[ "tg_notifications" = [nN] || "$silent" = 'quiet' ]]; then
      notify_opt=' -d disable_notification=true'
    else
      notify_opt=' -d disable_notification=false'
    fi
    curl -4s -F document=@"$file" "$tgapi/${tg_type}?chat_id=$tgchatid" |  jq -r '.result | {from: .from.first_name, to: .chat.first_name, date: .date | todate, document: .document.file_name, mime: .document.mime_type, size: .document.file_size }'
  else
    echo "file not found: $file"
  fi
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
  echo
  echo "send file"
  echo
  echo "$0 sendf filename"
}

case "$1" in
  sendf )
    tg_sendf file "$2"
    ;;
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
#!/bin/bash
#########################################################
# send message to your own Telegram Bot API
# using BotFather
# https://core.telegram.org/bots#3-how-do-i-create-a-bot
# https://core.telegram.org/bots/api#sendmessage
# https://core.telegram.org/bots/api#editmessagetext
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
tg_debug='n'
# insert message_id into messages via editMessageText
# https://core.telegram.org/bots/api#editmessagetext
tg_addmsgid='y'
# whether telegram notifications are enabled
tg_notifications='y'
# disable/enable web previews
tg_webpreview='n'
# curl --max-time and --connect-timeout for transfer/connect
tg_timeout='10'

script_dir=$(readlink -f $(dirname ${BASH_SOURCE[0]}))
#########################################################
if [ -f "${script_dir}/tgtoken.ini" ]; then
  . "${script_dir}/tgtoken.ini"
fi
if [ -f "/etc/centminmod/tgtoken.ini" ]; then
  . "/etc/centminmod/tgtoken.ini"
fi

if [ -z "$tgchatid" ]; then
  tgchatid=$(curl -4s "$tgapi/getUpdates" | jq -r '.result[].message.chat.id')
fi

tg_send() {
  format=$1
  message="$2"
  silent="$3"
  update="$4"
  input_msgid="$5"
  tg_type='sendMessage'

  if [[ "$format" = 'md' ]]; then
    format_opt=' -d parse_mode=MarkdownV2'
  elif [[ "$format" = 'html' ]]; then
    format_opt=' -d parse_mode=HTML'
  else
    format_opt=
  fi
  if [[ "$tg_notifications" = [nN] || "$silent" = 'quiet' ]]; then
    notify_opt=' -d "disable_notification=true"'
  else
    notify_opt=' -d "disable_notification=false"'
  fi
  if [[ "$tg_webpreview" = [yY] ]]; then
    webpreview_opt=' -d "disable_web_page_preview=false"'
  else
    webpreview_opt=' -d "disable_web_page_preview=true"'
  fi

  if [[ "$tg_debug" = [yY] ]]; then
    if [[ "$update" = 'update' ]]; then
      append_text="[msgid: $input_msgid Updated: $(date +"%a %d-%b-%y %T %Z")]  $message"
      tg_type='editMessageText'
      msgchar_count=$(echo $append_text | wc -m)
      json_output=$(curl -4s --connect-timeout $tg_timeout --max-time $tg_timeout -X POST "$tgapi/${tg_type}"${notify_opt}${webpreview_opt}${format_opt} -d message_id="$input_msgid" -d chat_id="$tgchatid" -d text="$append_text" |  jq -r)
    else
      msgchar_count=$(echo $message | wc -m)
      json_output=$(curl -4s --connect-timeout $tg_timeout --max-time $tg_timeout -X POST "$tgapi/${tg_type}"${notify_opt}${webpreview_opt}${format_opt} -d chat_id="$tgchatid" -d text="$message" |  jq -r)
    fi
    msgid=$(echo "$json_output" | jq -r '.result.message_id')
    if [[ "$tg_addmsgid" = [yY] && "$update" != 'update' ]]; then
      append_text="[msgid: $msgid] $message"
      tg_type='editMessageText'
      msgchar_count=$(echo $message | wc -m)
      json_output=$(curl -4s --connect-timeout $tg_timeout --max-time $tg_timeout -X POST "$tgapi/${tg_type}"${notify_opt}${webpreview_opt}${format_opt} -d message_id="$msgid" -d chat_id="$tgchatid" -d text="$append_text" |  jq -r)
    fi
    echo "$json_output"
    echo
    echo "message_id: $msgid"
    echo "message_char_count: $msgchar_count"
  else
    if [[ "$update" = 'update' ]]; then
      append_text="[msgid: $input_msgid Updated: $(date +"%a %d-%b-%y %T %Z")]  $message"
      tg_type='editMessageText'
      msgchar_count=$(echo $append_text | wc -m)
      json_output=$(curl -4s --connect-timeout $tg_timeout --max-time $tg_timeout -X POST "$tgapi/${tg_type}"${notify_opt}${webpreview_opt}${format_opt} -d message_id="$input_msgid" -d chat_id="$tgchatid" -d text="$append_text")
    else
      msgchar_count=$(echo $message | wc -m)
      json_output=$(curl -4s --connect-timeout $tg_timeout --max-time $tg_timeout -X POST "$tgapi/${tg_type}"${notify_opt}${webpreview_opt}${format_opt} -d chat_id="$tgchatid" -d text="$message")
    fi
    msgid=$(echo "$json_output" | jq -r '.result.message_id')
    if [[ "$tg_addmsgid" = [yY] && "$update" != 'update' ]]; then
      append_text="[msgid: $msgid] $message"
      tg_type='editMessageText'
      msgchar_count=$(echo $message | wc -m)
      json_output=$(curl -4s --connect-timeout $tg_timeout --max-time $tg_timeout -X POST "$tgapi/${tg_type}"${notify_opt}${webpreview_opt}${format_opt} -d message_id="$msgid" -d chat_id="$tgchatid" -d text="$append_text" |  jq -r)
    fi
    echo "$json_output" | jq -r '.result | {from: .from.first_name, to: .chat.first_name, date: .edit_date | todate, message: .text }'
  fi
}

tg_sendf() {
  format=$1
  file="$2"
  silent="$3"
  tg_type='sendDocument'

  if [[ "$format" = 'file' && -f "$file" ]]; then
    file="$file"
    if [[ "$tg_notifications" = [nN] || "$silent" = 'quiet' ]]; then
      notify_opt=' -d "disable_notification=true"'
    else
      notify_opt=' -d "disable_notification=false"'
    fi
    if [[ "$tg_debug" = [yY] ]]; then
      json_output=$(curl -4s --connect-timeout $tg_timeout --max-time $tg_timeout -F document=@"$file" "$tgapi/${tg_type}?chat_id=$tgchatid" |  jq -r)
      echo "$json_output"
    else
      json_output=$(curl -4s --connect-timeout $tg_timeout --max-time $tg_timeout -F document=@"$file" "$tgapi/${tg_type}?chat_id=$tgchatid" |  jq -r '.result | {from: .from.first_name, to: .chat.first_name, date: .date | todate, document: .document.file_name, mime: .document.mime_type, size: .document.file_size }')
      echo "$json_output"
    fi
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
  echo "update existing message with message_id:"
  echo
  echo "$0 update \"your message in double quotes\" message_id"
  # echo "$0 updatemd \"your message in double quotes\" message_id"
  echo "$0 updatehtml \"your message in double quotes\" message_id"
  echo
  echo "update existing message with message_id & disable notifications:"
  echo
  echo "$0 updateq \"your message in double quotes\" message_id"
  # echo "$0 updatemdq \"your message in double quotes\" message_id"
  echo "$0 updatehtmlq \"your message in double quotes\" message_id"
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
    tg_send txt "$2" verbose
    ;;
  sendmd )
    tg_send md "$2" verbose
    ;;
  sendhtml )
    tg_send html "$2" verbose
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
  update )
    tg_send txt "$2" verbose update "$3"
    ;;
  updatemd )
    tg_send md "$2" verbose update "$3"
    ;;
  updatehtml )
    tg_send html "$2" verbose update "$3"
    ;;
  updateq )
    tg_send txt "$2" quiet update "$3"
    ;;
  updatemdq )
    tg_send md "$2" quiet update "$3"
    ;;
  updatehtmlq )
    tg_send html "$2" quiet update "$3"
    ;;
  * )
    help
    ;;
esac
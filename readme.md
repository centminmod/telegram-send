# tgsend.sh

Send message or text files to your own Telegram Bot API created using BotFather:

* https://core.telegram.org/bots#3-how-do-i-create-a-bot
* https://core.telegram.org/bots/api#sendmessage

## Telegram BotFather

![Telegram BotFather Bot Creation](/images/telegram-botfather-01.png)

# Dependencies

Requires jq json tool install:

```
apt-get -y install jq
```
or 
```
yum -y install jq
```

# Usage

Create and populate `tgtoken.ini` file in same directory as tgsend.sh with the following:

```
tgtoken='YOUR_TELEGRAM_BOT_API_TOKEN'
tgchatid='YOUR_TELEGRAM_CHATID'
tgapi="https://api.telegram.org/bot$tgtoken"
```

You can find your Telegram chat id to populate variable `tgchatid` using the following command:

```
tgtoken='YOUR_TELEGRAM_BOT_API_TOKEN'
tgapi="https://api.telegram.org/bot$tgtoken

curl -4s "$tgapi/getUpdates" | jq -r '.result[].message.chat.id'
```

Available commands:

```
./tgsend.sh 

Usage:

./tgsend.sh send "your message in double quotes"
./tgsend.sh sendhtml "your message in double quotes"

disable notifications:

./tgsend.sh sendq "your message in double quotes"
./tgsend.sh sendhtmlq "your message in double quotes"

send file

./tgsend.sh sendf filename
```

# Examples

## Send messages in plain text or HTML format

```
./tgsend.sh send "message text"
{
  "from": "centmin",
  "to": "George",
  "date": "2021-07-05T08:13:12Z",
  "message": "message text"
}
```
```
./tgsend.sh sendhtml "message <i>html</i>"
{
  "from": "centmin",
  "to": "George",
  "date": "2021-07-05T08:13:20Z",
  "message": "message html"
}
```
```
./tgsend.sh send "$(free -mlt)"
{
  "from": "centmin",
  "to": "George",
  "date": "2021-07-06T00:30:14Z",
  "message": "total        used        free      shared  buff/cache   available\nMem:          31973        7189        2183        2229       22600       22162\nLow:          31973       29789        2183\nHigh:             0           0           0\nSwap:          2045           3        2042\nTotal:        34019        7192        4226"
}
```

![Telegram Messages](/images/telegram-send-04.png)

## Send text file

```
./tgsend.sh sendf test.txt
{
  "from": "centmin",
  "to": "George",
  "date": "2021-07-05T08:50:19Z",
  "document": "test.txt",
  "mime": "text/plain",
  "size": 2
}
```

![Telegram File Send](/images/telegram-send-03.png)
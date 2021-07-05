# Usage

```
./tgsend.sh 

Usage:

./tgsend.sh send "your message in double quotes"
./tgsend.sh sendhtml "your message in double quotes"

disable notifications:

./tgsend.sh sendq "your message in double quotes"
./tgsend.sh sendhtmlq "your message in double quotes"
```

# Examples

```
./tgsend.sh send "message text"
{
  "from": "centmin",
  "to": "George",
  "date": "2021-07-05T07:41:09Z",
  "message": "message text"
}
```
```
./tgsend.sh sendhtml "message <i>html</i>"
{
  "from": "centmin",
  "to": "George",
  "date": "2021-07-05T07:40:04Z",
  "message": "message html"
}
```
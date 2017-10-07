#!/bin/bash

mkdir /tmp/youtube-dl-manager
#Formating list
tail -n+2 /home/pi/downloadList | tr ' ' '\n' > /tmp/youtube-dl-manager/audiosQueue
head -n1 /home/pi/downloadList | tr ' ' '\n' > /tmp/youtube-dl-manager/videosQueue

echo '## Audio list:'
cat /tmp/youtube-dl-manager/audiosQueue
echo '## Video list:'
cat /tmp/youtube-dl-manager/videosQueue

#Confirm List is ok
read -p "Are these lists correct? [y/n]: " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  cat /tmp/youtube-dl-manager/audiosQueue >> /home/pi/media/audiosQueue
  cat /tmp/youtube-dl-manager/videosQueue >> /home/pi/media/videosQueue
  > /home/pi/downloadList #empty file
  echo
  echo '## Downloading:'
  echo
  echo '## Audio list:'
  cat /home/pi/media/audiosQueue
  echo '## Video list:'
  cat /home/pi/media/videosQueue
  > /tmp/youtube-dl-manager/output
  tail -f /tmp/youtube-dl-manager/output >/dev/stdout &
  tail_pid=$!
  cat /home/pi/media/audiosQueue | xargs -I% bash -c "youtube-dl -x '%' >/tmp/youtube-dl-manager/output && tail -n+2 /home/pi/media/audiosQueue > /tmp/youtube-dl-manager/audiosQueue && mv /tmp/youtube-dl-manager/audiosQueue /home/pi/media/audiosQueue && grep Destination /tmp/youtube-dl-manager/output | head -n1 | cut -d\  -f3- | cut -d. -f-1 >> /home/pi/media/audiosDownloaded"
  cat /home/pi/media/videosQueue | xargs -I% bash -c "youtube-dl -f 'bestvideo[height<=720]+bestaudio/best[height<=720]' '%' >/tmp/youtube-dl-manager/output && tail -n+2 /home/pi/media/videosQueue > /tmp/youtube-dl-manager/videosQueue && mv /tmp/youtube-dl-manager/videosQueue /home/pi/media/videosQueue && grep Destination /tmp/youtube-dl-manager/output | head -n1 | cut -d\  -f3- | cut -d. -f-1 >> /home/pi/media/videosDownloaded"
  kill $tail_pid
else
  rm /tmp/youtube-dl-manager/audiosQueue /tmp/youtube-dl-manager/videosQueue
fi

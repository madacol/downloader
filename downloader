#!/bin/bash

### Config vars
download_list='/home/pi/downloadList'
download_dir='/home/pi/media/'
video_dir=$download_dir'videos'
audio_dir=$download_dir'audios'
temp_dir='/tmp/youtube-dl-manager/'
tail_pid=$temp_dir'tailPid'
###

test -s $temp_dir || mkdir $temp_dir
if [[ -s $download_list ]]; then
  tail -n+2 $download_list | tr ' ' '\n' > $temp_dir'audiosQueue'
  head -n1 $download_list | tr ' ' '\n' > $temp_dir'videosQueue'

  echo '## Audio list:'
  cat $temp_dir'audiosQueue'
  echo '## Video list:'
  cat $temp_dir'videosQueue'

  #Confirm List is ok
  echo
  read -p "Add lists to Queue? [y/n]: " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat $temp_dir'audiosQueue' >> $download_dir'audiosQueue'
    cat $temp_dir'videosQueue' >> $download_dir'videosQueue'
    > $download_list #empty file
    echo
    echo 'Added to Queue lists'
  else
    rm $temp_dir'audiosQueue' $temp_dir'videosQueue'
  fi
  echo
fi
echo
echo '### Queue lists:'
echo
echo '## Audio list:'
cat $download_dir'audiosQueue'
echo '## Video list:'
cat $download_dir'videosQueue'
echo

#Confirm to start downloading
read -p "Download lists? [y/n]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo '### Downloading...'
  test -s $tail_pid && kill $(cat $tail_pid) && > $tail_pid # Check if tail_pid exist, then kill it, and empty tail_pid
  > $temp_dir'output'
  tail -f $temp_dir'output' >/dev/stdout &
  echo $! > $tail_pid
  cat $download_dir'audiosQueue' | xargs -I%% bash -c "youtube-dl -x '%%' >"$temp_dir"output && sed -i '/'\$(echo '%%' | rev | cut -d/ -f1 | rev)'/d' "$download_dir"audiosQueue && grep Destination "$temp_dir"output | head -n1 | cut -d\  -f3- | cut -d. -f-1 | awk '{print \"%% - \"\$0}' >> "$download_dir"audiosDownloaded"
  cat $download_dir'videosQueue' | xargs -I%% bash -c "youtube-dl -f 'best[height<=720]/bestvideo[height<=720]+bestaudio' '%%' >"$temp_dir"output && sed -i '/'\$(echo '%%' | rev | cut -d/ -f1 | rev)'/d' "$download_dir"videosQueue && grep Destination "$temp_dir"output | head -n1 | cut -d\  -f3- | cut -d. -f-1 | awk '{print \"%% - \"\$0}' >> "$download_dir"videosDownloaded"
  kill $(cat $tail_pid) && rm $tail_pid
fi

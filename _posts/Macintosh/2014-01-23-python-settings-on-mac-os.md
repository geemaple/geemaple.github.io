---
layout: post
title: "Mac - 环境配置"
date:   2014-01-23
categories: Macintosh
tags: Mac
excerpt: Life is short, I use python
---

* content
{:toc}

> 系统自带的Python, Ruby等是给系统必要程序用的，并不是给开发者使用的

## Homebrew

```sh
export PATH="/opt/homebrew/bin:$PATH"
if ! command -v brew &> /dev/null; then
  # Install Homebrew + python
  echo "--installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(brew shellenv)"
brew_dir=$(brew --prefix)
brew_install=$(brew list)
```

### Python
```sh
# python
if ! echo "$brew_install" | grep -q 'pyenv'; then
  echo "install python"
  brew install pyenv pyenv-virtualenvwrapper
  pyenv install 3.12.0
  pyenv global 3.12.0
  pyenv rehash
  export PATH="$brew_dir/opt/python/bin:$PATH"
fi

PYENV_ROOT="$HOME/.pyenv"
PATH="/usr/local/opt/python/libexec/bin:$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
pyenv virtualenvwrapper_lazy
```

### Ruby

```sh
# ruby
if ! echo "$brew_install" | grep -q 'ruby'; then
   echo "install ruby"
   brew install ruby
   export PATH="$brew_dir/opt/ruby/bin:$PATH"
fi
```

### FFMPEG

```sh
# ffmpeg
if ! echo "$brew_install" | grep -q 'ffmpeg'; then
  echo "install ffmpeg"
  brew install ffmpeg
fi

# ffmpeg
alias ffresolution='ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0'
alias ffduration='ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1'
alias ffframerate='ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1'
alias ffbitrate='ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1'

function ff1k { if [ -d "$1" ]; then for input in "$1"/*; do _video_process "$input" 1920x1080 3M 1k; done; else _video_process "$1" 1920x1080 3M 1k; fi; }
function ff2k { if [ -d "$1" ]; then for input in "$1"/*; do _video_process "$input" 2560x1440 3M 2k; done; else _video_process "$1" 2560x1440 3M 2k; fi; }
function ff4k { if [ -d "$1" ]; then for input in "$1"/*; do _video_process "$input" 3840x2160 3M 4k; done; else _video_process "$1" 3840x2160 3M 4k; fi; }
function ffrewrite { if [ -d "$1" ]; then for input in "$1"/*; do _video_process "$input"; done; else _video_process "$1"; fi; }
function ffaudio { if [ -d "$1" ]; then for input in "$1"/*; do _audio_process "$input"; done; else _audio_process "$1"; fi; }

function ff2gif {
  FILE=$1
  ffmpeg -i $FILE -vf fps=10,scale=800:-1 ${FILE%.*}.gif
}

function ffabps {
  input_file=$1

  duration_seconds=$(ffduration "$input_file")
  file_size_bytes=$(stat -f "%z" "$input_file")
  average_bitrate=$(echo "scale=0; $file_size_bytes * 8 / $duration_seconds" | bc)

  echo $average_bitrate
}

function _audio_process {
  local input="$1"
  if ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 "$input" 2>/dev/null | grep -q video; then
    local filename_with_extension=$(basename "$input")
    local extension="${input##*.}"
    local filename="${filename_with_extension%.*}"
    # ffmpeg -i "$input" -c:a aac "${filename}.aac"
    ffmpeg -i "$input" -c:a pcm_s16le "${filename}.wav"
  else
    echo "skip $input (no audio stream detected)"
  fi
}

function _video_process {
  local input="$1"
  local resolution="$2"
  local bitrate="$3"
  local mark="$4"
  if ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 $input 2>/dev/null | grep -q video; then
    local frame_rate=$(ffframerate "$input")
    local filename_with_extension=$(basename "$input")
    local extension="${input##*.}"
    local filename="${filename_with_extension%.*}"
    local directory=$(dirname "$input")
    local subtitle=$(find $directory -type f -name "$filename.*" | grep -i -m 1 -E '\.srt$|\.sub$|\.ass$|\.ssa$')

    if [ -z "$resolution" ]; then
      resolution=$(ffresolution "$input")
      echo "default resolution = $resolution"
    fi

    if [ -z "$bitrate" ]; then
      bitrate=$(ffabps "$input")
      echo "default bitrate = $bitrate"
    fi  

    if [ -e "$subtitle" ]; then
      local output="${filename}_subtitle.${extension}"
      ffmpeg -i "$input" -s $resolution -color_range 2 -vf "subtitles=${subtitle}'" -c:v hevc_videotoolbox -tag:v hvc1 -c:a copy -b:v $bitrate -r $frame_rate "$output"
    else
      local output="${filename}_${mark:-rewrite}.${extension}"
      echo $output
      ffmpeg -i "$input" -s $resolution -color_range 2 -c:v hevc_videotoolbox -tag:v hvc1 -c:a copy -b:v $bitrate -r $frame_rate "$output"
    fi
  else
      echo "skip $input"
  fi
}
```

### Jackett

```sh
if ! echo "$brew_install" | grep -q 'jackett'; then
  echo "install jackett"
  brew install jackett
  brew services start jackett
  echo "visist http://127.0.0.1:9117/ and install jackett.py search plugin to qbittorrent"
fi
```

## 其他工具

### 定时休眠

```sh
function gn { 
  countdown=$(echo "$*" | bc)
  while [ $countdown -gt 0 ]; do
    echo -ne "\033]0;$countdown\007"
    echo -ne "Sleep in $countdown seconds...\r"
    sleep 1
    ((countdown--))
  done
  echo -ne "Sleep in $countdown seconds...\n"
  pmset sleepnow
}

function blackout {
  countdown=$(echo "$*" | bc)
  while [ $countdown -gt 0 ]; do
    echo -ne "\033]0;$countdown\007"
    echo -ne "Blackout in $countdown seconds...\r"
    sleep 1
    ((countdown--))
  done
  echo -ne "Blackout in $countdown seconds...\n"
  pmset displaysleepnow
}
```

### 加密压缩

```sh
alias zip_secret="zip -e"
```

### 网络测试

```sh
alias test_tcp="nc -vz" 
alias test_udp="nc -vuz"
```

### 文件整理

```sh
function find_k_large { sudo find "${1:-.}" -type f -exec du -h {} + | sort -rh | head -n ${2:-10}; }
function find_duplicate { 
  sudo find "${1:-.}" -type f -exec md5 {} + | awk -F'=' '{ gsub(/MD5 /, "", $0); print $2, $1 }' | sort -k1 | awk '{
    hash = $1;
    file = substr($0, index($0, $2));
    if (count[hash]++) {
        files[hash] = files[hash] "vs. " file;
    } else {
        files[hash] = file;
    }
}
END {
    for (hash in files) {
        if (count[hash] > 1) {
            print hash ": " files[hash];
        }
    }
}'; }
```

### 备份

```sh
function rsync_backup { sudo rsync -avh --delete $1 $2;}
function rsync_copy { sudo rsync -avh --backup --suffix=.bak $1 $2;}
function mac_backup {
  local SRC_DIRS=(
    "$HOME"
    /Applications
  )

  local BASE=$(basename "$HOME")
  local FILTER=$(cat <<EOF
+ $BASE/Library/Application Support/***
+ $BASE/Library/Preferences/***
+ $BASE/Library/Saved Application State/***
+ $BASE/Library/Keychains/***
+ $BASE/Library/Containers/***
+ $BASE/Library/Group Containers/***
- $BASE/Library/**
- $BASE/Downloads
- Applications/Safari.app
- Applications/Xcode.app
- Applications/iMovie.app
- Applications/Utilities
- .Trash
EOF
)
  local DEST="/Volumes/TimeMachine"
  local LAST_BACKUP="$DEST/last-backup"
  local FILTER_FILE="/tmp/backup-filter.txt"
  local NEW_BACKUP="$DEST/backup-$(date +%Y-%m-%d)"
  local BAD_BACKUP="$DEST/corrupt-$(date +%Y-%m-%d)"
  
  if [ -d "$BAD_BACKUP" ]; then 
    mv "$BAD_BACKUP" "$NEW_BACKUP"
  else
    mkdir -p "$NEW_BACKUP"
  fi

  echo "$FILTER" > "$FILTER_FILE"
  if [ -f "$FILTER_FILE" ]; then
    FILTER_ARGS="merge $FILTER_FILE"
  else
    echo "Exclude file $FILTER_FILE does not exist. Skipping exclusions."
    FILTER_ARGS=""
  fi

  echo "Running rsync with the following command:"  
  echo "sudo rsync -ah --stats --delete --filter='$FILTER_ARGS' ${SRC_DIRS[@]} $NEW_BACKUP --dry-run"
  local RSYNC_OUTPUT=$(`sudo rsync -ah --delete --filter=$FILTER_ARGS "${SRC_DIRS[@]}" "$NEW_BACKUP" 2>&1`)
  local RSYNC_EXIT_CODE=$?

  echo "$RSYNC_OUTPUT"
  # Check rsync exit status
  if [ $RSYNC_EXIT_CODE -eq 0 ]; then
    echo "Backup completed successfully."
  else
    echo "Backup failed with error code $RSYNC_EXIT_CODE. Details:"
    echo "$RSYNC_OUTPUT"    
    mv "$NEW_BACKUP" "$BAD_BACKUP"
    return 1
  fi
}

function mac_restore {
  local DEST="/Volumes/TimeMachine"
  
  # List available backups
  local backups=($(ls -1 $DEST | grep '^backup-' | sort -r))
  if [ ${#backups[@]} -eq 0 ]; then
    echo "No backups found."
    return 1
  fi
  
  # Display backup options
  echo "Available backups:"
  select backup in "${backups[@]}"; do
    if [[ -n "$backup" ]]; then
      echo "You selected $backup"
      local BACKUP_DIR="$DEST/$backup"
      break
    else
      echo "Invalid selection. Please try again."
    fi
  done
  
  # Perform the restore using rsync
  local SRC_DIRS=(
    "$HOME"
    "/Applications"
  )

  # Restore files from selected backup
  for SRC in "${SRC_DIRS[@]}"; do
    echo "Restoring from $BACKUP_DIR/$(basename "$SRC") to $SRC"
    sudo rsync -ah --backup --suffix=.bak "$BACKUP_DIR/$(basename "$SRC")/" "$SRC/"
  done

  # Check rsync exit status
  if [ $? -eq 0 ]; then
    echo "Restore completed successfully."
  else
    echo "Restore failed with error code $?."
    return 1
  fi
}
```

## pyenv基本用法

### 安装python
```sh
pyenv install --list 
pyenv install 3.12.0
pyenv rehash
```

### 删除python
```sh
pyenv versions # 所有版本
pyenv version # 当前版本
pyenv uninstall 3.12.0
```

### 创建virtualenv

```sh
mkvirtualenv testing
workon testing

pip install tensorflow
```

### 删除virtualenv
```sh
deactivate #或者切换到其他python虚拟环境中
rmvirtualenv testing
```

-- End --

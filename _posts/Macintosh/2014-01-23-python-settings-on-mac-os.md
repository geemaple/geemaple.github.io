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

function ff1k { if [ -d "$1" ]; then for input in "$1"/*; do ffscales "$input" 1920x1080 3M 1k; done; else ffscales "$1" 1920x1080 3M 1k; fi; }
function ff2k { if [ -d "$1" ]; then for input in "$1"/*; do ffscales "$input" 2560x1440 3M 2k; done; else ffscales "$1" 2560x1440 3M 2k; fi; }
function ff4k { if [ -d "$1" ]; then for input in "$1"/*; do ffscales "$input" 3840x2160 3M 4k; done; else ffscales "$1" 3840x2160 3M 4k; fi; }
function ffcopy { if [ -d "$1" ]; then for input in "$1"/*; do ffrewrite "$input"; done; else ffrewrite "$1"; fi; }
function ffmp3 { ffmpeg -i "$1" -acodec libmp3lame -aq 2 output.mp3; }

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

function ffscales {
  local input="$1" resolution="$2" bitrate="$3" mark="$4"
  if ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 $input 2>/dev/null | grep -q video; then
    local frame_rate=$(ffframerate "$input")
    local filename_with_extension=$(basename "$input")
    local extension="${input##*.}"
    local filename="${filename_with_extension%.*}"
    local output="${filename}_${mark}.${extension}"
    ffmpeg -i "$input" -s $resolution -color_range 2 -c:v hevc_videotoolbox -tag:v hvc1 -c:a copy -b:v $bitrate -r $frame_rate "$output"
  else
      echo "skip $input"
  fi
}

function ffrewrite {
  local input="$1"
  if ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 $input 2>/dev/null | grep -q video; then
    local input="$1"
    local resolution=$(ffresolution "$input")
    local frame_rate=$(ffframerate "$input")
    local bitrate=$(ffabps "$input")
    local filename_with_extension=$(basename "$input")
    local extension="${input##*.}"
    local filename="${filename_with_extension%.*}"
    local directory=$(dirname "$input")
    local subtitle=$(find $directory -type f -name "$filename.*" | grep -i -m 1 -E '\.srt$|\.sub$|\.ass$|\.ssa$')

    if [ -e "$subtitle" ]; then
      local output="${filename}_subtitle.${2-$extension}"
      ffmpeg -i "$input" -s $resolution -color_range 2 -vf "subtitles=${subtitle}'" -c:v hevc_videotoolbox -tag:v hvc1 -c:a copy -b:v $bitrate -r $frame_rate "$output"
    else
      local output="${filename}_rewrite.${2-$extension}"
      ffmpeg -i "$input" -s $resolution -color_range 2 -c:v hevc_videotoolbox -tag:v hvc1 -c:a copy -b:v $bitrate -r $frame_rate "$output"
    fi
  else
      echo "skip $input"
  fi
}
```

## 其他工具

```sh
function gn { sleep $1; pmset sleepnow; }

alias zip_secret="zip -e"
alias rsync_backup="rsync -avh --progress --delete"
alias rsync_copy="rsync -avh --progress --backup"
alias test_tcp="nc -vz" 
alias test_udp="nc -vuz"
function find_k_large { find "${1:-.}" -type f -exec du -h {} + | sort -rh | head -n ${2:-10}; }
function find_duplicate { 
  find "${1:-.}" -type f -exec md5 {} + | awk -F'=' '{ gsub(/MD5 /, "", $0); print $2, $1 }' | sort -k1 | awk '{
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

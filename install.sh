#!/usr/bin/env bash

set -o pipefail

DENO_REPO_URL="https://github.com/denoland/deno"
LATEST_RELEASE_URL="$DENO_REPO_URL/releases/latest"
TAG_RELEASE_URL="$DENO_REPO_URL/releases/tag"

DENO_DIR="$HOME/.deno"
DENO_BIN_DIR="$DENO_DIR/bin"
DENO_BIN="$DENO_BIN_DIR/deno"
DENO_LINK=/usr/local/bin/deno

print_help () {
  echo "deno-bash-installer"
  echo "usage: sudo bash $0 [version tag, fx v0.2.1]"
}

panic () { # error
  [[ -n $1 ]] && echo "[deno-bash-installer error] $1" >&2
  exit 1
}

pinup () { # info
  echo "[deno-bash-installer info] $1"
}

release_url () { # tag?
  case $OSTYPE in
    darwin*) filename="deno_osx_x64.gz";;
    linux*) filename="deno_linux_x64.gz";;
    *) panic "unsupported platform $OSTYPE";;
  esac
  [[ -n $1 ]] && url="$TAG_RELEASE_URL/$1" || url=$LATEST_RELEASE_URL
  match=$(curl -sL $url | grep href | grep $filename | grep -o '/deno[^"]*')
  [[ -z $match ]] && panic "unable to find download url for $filename @ $url"
  echo "https://github.com$match"
}

download () { # url bin
  curl --progress-bar -L $1 | gunzip > $2
}

mk_handy () { # deno_dir bin
  chown -R $SUDO_USER $1
  sudo -u $SUDO_USER chmod -R 744 $1
  [[ ! -L $DENO_LINK ]] && ln -s $2 $DENO_LINK
}

main () { # tag?
  for opt in $@; do case $opt in
    -h|--help) print_help; exit 0;;
  esac; done
  [[ $1 =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] && v=$1
  [[ -n $v ]] && pinup "installing deno $v" || pinup "installing deno@latest"
  url=$(release_url $v)
  mkdir -p $DENO_BIN_DIR
  pinup "downloading $url > $DENO_BIN"
  download $url $DENO_BIN
  [[ ! -f $DENO_BIN ]] && panic "download failed"
  pinup "plugging up da binary"
  mk_handy $DENO_DIR $DENO_BIN
  deno --version 2> /dev/null 
  [[ $? -eq 0 ]] && pinup "setup ok" || panic "setup failed"
  exit 0
}

main "$@"

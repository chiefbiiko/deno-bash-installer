#!/usr/bin/env bash

set -Eeo pipefail

DENO_REPO_URL="https://github.com/denoland/deno"
LATEST_RELEASE_URL="$DENO_REPO_URL/releases/latest"
TAG_URL="$DENO_REPO_URL/releases/tag"

print_help () {
  echo "deno-bash-installer"
  echo "usage: sudo bash $0 [ -t, --tag  specific deno version ] [ -h, --help ]"
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
    *linux*) filename="deno_linux_x64.gz";;
    *) panic "unsupported platform $OSTYPE";;
  esac
  if [[ -n $1 ]]; then url="$TAG_URL/$1"; else url=$LATEST_RELEASE_URL; fi
  pinup "fetching deno releases"
  html=$(curl --progress-bar -sL $url)
  match=$(echo $html | grep href | grep $filename | grep -o '/deno[^"]*')
  [[ -z $match ]] && panic "unable to find download url for $filename"
  echo "https://github.com$match"
}

deno_bin_dir () {
  bin_dir="$HOME/.deno/bin"
  mkdir -p bin_dir
  echo bin_dir
}

download () { # url bin
  pinup "downloading $1 > $2"
  curl --progress-bar -sL $1 | gunzip > $2
}

mk_handy () { # bin_dir bin
  pinup "plugging up the binary and yo path"
  chmod 744 $2
  [[ ":$PATH:" -ne *"$HOME/.deno/bin"* ]] && PATH="$1:$PATH"
}

main () { # tag?
  url=$(release_url $1)
  bin_dir=$(deno_bin_dir)
  bin="$bin_dir/deno"
  download $url $bin
  [[ $? -ne 0 ]] && panic "download failed"
  mk_handy $bin_dir $bin
  [[ $? -ne 0 ]] && panic "installation failed"
  pinup "successful installation"
  echo "$(deno --version)"
  exit 0
}

for opt in $@; do case $opt in
  -h|--help) print_help; exit 0;
esac; done

main $1

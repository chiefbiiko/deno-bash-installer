#!/usr/bin/env bash

set -Eeo pipefail

DENO_REPO_URL="https://github.com/denoland/deno"
LATEST_RELEASE_URL="$DENO_REPO_URL/releases/latest"
TAG_URL="$DENO_REPO_URL/releases/tag"

print_help () {
  echo "deno-bash-installer"
  echo "usage: bash $0 [ -t, --tag  specific deno version ] [ -h, --help ]"
}

panic () { # error
  [[ -n $1 ]] && echo "[deno-bash-installer error] $1" >&2
  exit 1
}

pinup () { # info
  echo "[deno-bash-installer info] $1"
}

release_url () { # tag
  case $OSTYPE in
    darwin) filename="deno_osx_x64.gz";;
    linux|linux2) filename="deno_linux_x64.gz";;
    win32|cygwin) filename="deno_win_x64.zip";; #???
    *) panic "unsupported platform $1";;
  esac
  if [[ -n $2 ]]; then
    url="$TAG_URL/$2"
  else
    url=$LATEST_RELEASE_URL
  fi
  match=$(curl -L $url | grep href | grep $filename | grep -o '/deno[^"]*')
  [[ -z $match ]] && panic "unable to find download url for $filename"
  echo "https://github.com$match"
}

deno_bin () {
  bin_dir="$HOME/.deno/bin"
  mkdir -p bin_dir
  bin="$bin_dir/deno"
  echo bin
}

download_install () { # url bin
  #curl -L $1 | unzip -o deno.exe > $2 # HOMEWORK
}

main () { # tag?
  bin=$(deno_bin)
  url=$(release_url $1)
  download_install $url $bin
  # TODO: maybe append 2 $PATH, verify install n exit
}

for opt in $@; do case $opt in
  -h|--help) print_help; exit 0;
esac; done

#main $1
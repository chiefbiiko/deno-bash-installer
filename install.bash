#!/usr/bin/env deno

set -Eeo pipefail

DENO_REPO_URL="https://github.com/denoland/deno"
LATEST_RELEASE_URL="$DENO_REPO_URL/releases/latest"
TAG_URL="$DENO_REPO_URL/releases/tag"

print_help () {
  echo "deno-bash-installer"
  echo "usage: bash $0"
}

panic () {
  [[ -n $1 ]] && echo "[deno-bash-installer error] $1" >&2
  exit 1
}

pinup () {
  echo "[deno-bash-installer info] $1"
}

release_url () { # platform, tag
  case $1 in
    darwin) filename="deno_osx_x64.gz";;
    linux|linux2) filename="deno_linux_x64.gz";;
    win32|cygwin) filename="deno_win_x64.zip";;
    *) panic "unsupported platform";;
  esac
  if [[ -n $2 ]]; then
    url="$TAG_URL/$2"
  else
    url=$LATEST_RELEASE_URL
  fi
  match=$(curl -L $url | grep href | grep $filename | grep -o '/[^"]*')
  [[ -z $match ]] && panic "unable to find download url for $filename"
  echo "https://github.com$match"
}

for opt in $@; do case $opt in
  -h|--help) print_help; exit 0;
esac; done

#
release_url "darwin" "v0.1.12"
#

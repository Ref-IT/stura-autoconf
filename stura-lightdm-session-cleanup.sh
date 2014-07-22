#! /bin/sh

set -e

for i in /etc/lightdm/PostLogout/*; do
  if [ -x "$i" ]; then
    $i "$*"
  fi
done

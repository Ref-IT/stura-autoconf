#! /bin/sh

set -e

for i in /etc/lightdm/PostLogin/*; do
  if [ -x "$i" ]; then
    $i "$*"
  fi
done

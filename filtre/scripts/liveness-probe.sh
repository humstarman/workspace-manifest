#!/bin/bash
FILES=$(cat /etc/haproxy/watch.lst)
for FILE_NAME in $FILES; do
  FILE="/etc/haproxy/${FILE_NAME}"
  SHA="/tmp/${FILE_NAME}.sha256"
  if [ ! -f "$SHA" ]; then
    sha256sum $FILE | awk -F ' ' '{print $1}' > $SHA
  else
    X=$(cat $SHA)
    Y=$(sha256sum $FILE | awk -F ' ' '{print $1}')
    if [ "$X" != "$Y" ]; then
      exit 1
    fi
  fi
done
exit 0

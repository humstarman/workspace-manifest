#!/bin/bash

NAMESPACE=gitlab
TARGET="metadata:"
ADDITION="namespace: $NAMESPACE"
FILES="$(find ./ -name '*.yaml' -type f)"

for FILE in $FILES; do
  echo $FILE
  IF0=$(cat $FILE | grep "$ADDITION")
  if [ -z "$IF0" ]; then
    sed -i "/^$TARGET$/a {{.placeholder}}  $ADDITION" $FILE
    sed -i s"/{{.placeholder}}//g" $FILE
  else
    echo "already have field -> $ADDITION"
    echo "skip"
    echo "==="
  fi
done

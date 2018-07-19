#!/bin/bash
set -e
show_help () {
cat << USAGE
usage: $0 [ -s NAMESPACE ]
    -s : Specify the namespace.
USAGE
exit 0
}
# Get Opts
while getopts "hs:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    s)  NAMESPACE=$OPTARG
        ;;
    ?)  # 当有不认识的选项的时候arg为?
        echo "unkonw argument"
        exit 1
        ;;
    esac
done
[ -z "$*" ] && show_help
chk_install () {
if [ ! -x "$(command -v $1)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no $1 installed !!!"
  sleep 3
  exit 1
fi
}
NEEDS="kubectl"
for NEED in $NEEDS; do
  chk_install $NEED
done
[[ "default" == "$NAMESPACE" ]] && exit 0
if kubectl get ns | grep ${NAMESPACE}; then exit 0; fi
FILE=./manifest/namespace.yaml
cat > $FILE <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: "${NAMESPACE}"
  labels:
    name: "${NAMESPACE}"
EOF

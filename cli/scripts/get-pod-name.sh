#!/bin/bash
set -e
DEFAULT_S="default"
show_help () {
cat << USAGE
usage: $0 [ -N CONTROLLER-NAME ] [ -s NAMESPACE ]
    -n : Specify the name of the controller.
    -s : Specify the namespace. If not specified, use '${DEFAULT_S}' by default.
USAGE
exit 0
}
# Get Opts
while getopts "hn:s:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    n)  NAME=$OPTARG
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
chk_var () {
if [ -z "$2" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no input for \"$1\", try \"$0 -h\"."
  sleep 3
  exit 1
fi
}
chk_var -n $NAME
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
NAMESPACE=${NAMESPACE:-"${DEFAULT_S}"}
POD=$(kubectl -n ${NAMESPACE} get pod | grep ${NAME} | awk -F ' ' '{print $1}')
echo $POD

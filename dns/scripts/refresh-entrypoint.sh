#!/bin/bash
set -e
show_help () {
cat << USAGE
usage: $0 [ -P REFRESH-PATH ]
    -p : Specify the path of the refresh, for instance: "cm2sh" or "sh2cm".
USAGE
exit 0
}
# Get Opts
while getopts "hp:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    p)  RPATH=$OPTARG
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
chk_var -p $RPATH
CM=./manifest/entrypoint-cm.yaml.sed
ENTRY=./scripts/entrypoint.sh
RPATH=$(echo $RPATH | tr '[:lower:]' '[:upper:]')
if [[ "CM2SH" == "${RPATH}" ]]; then
  N=$(sed -n -e /"#!"/= $CM)
  if [[ "$N" > "2" ]]; then
    N=$[N-1]
    sed "1,$N"d $CM | sed s/"    "/""/g > $ENTRY 
  fi
elif [[ "SH2CM" == "${RPATH}" ]]; then
  N=$(sed -n -e /"#!"/= $CM)
  [ -z $N ] || sed -i "$N,$"d $CM 
  sed s/"^"/"    "/g $ENTRY >> $CM
else
  echo "unkonw argument: ${RPATH}"
  exit 1
fi

#!/bin/bash
show_help () {
cat << USAGE
usage: $0 [ -d DAEMONSET ]
    -d : Specify the name of the daemonset object.
USAGE
exit 0
}
# Get Opts
while getopts "hd:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    d)  DS=$OPTARG
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
chk_var -d $DS
INFO=$(kubectl get po -o wide | grep $DS)
#echo $INFO
N=$(kubectl get po -o wide | grep $DS | wc -l)
#echo $N
for i in $(seq -s ' ' $[1+1] $[$N+1]); do
  GROUP=$(echo $INFO | awk -F "$DS" -v j=$i '{print $j}')
  #echo $GROUP
  POD=$(echo $GROUP | awk -F ' ' '{print $6}')
  HOST=$(echo $GROUP | awk -F ' ' '{print $7}')
  if ping -c 1 $POD >/dev/null 2>&1; then
    echo "$POD on $HOST is: good"
  else
    echo "$POD on $HOST is: NOT good"
  fi 
done

#!/bin/bash
show_help () {
cat << USAGE
usage: $0 [ -d DAEMONSET ]
    -d : Specify the name of the daemonset object.
    -l : Specify the loops to wait. If not specified, use '10' by default.
    -s : Specify the time to sleep in each loop. If not specified, use '3' by default.
USAGE
exit 0
}
# Get Opts
while getopts "hd:l:s:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    d)  DS=$OPTARG
        ;;
    l)  LOOPS=$OPTARG
        ;;
    s)  SLEEP=$OPTARG
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
SLEEP=${SLEEP:-"3"}
LOOPS=${LOOPS:-"10"}
INFO=$(kubectl get po -o wide | grep $DS)
#echo $INFO
N=$(kubectl get po -o wide | grep $DS | wc -l)
#echo $N
echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - wating for $DS to start..."
for TMP in $(seq -s ' ' 1 ${LOOPS}); do
  INFO=$(kubectl get po -o wide | grep $DS)
  N2=0
  for i in $(seq -s ' ' $[1+1] $[$N+1]); do
    GROUP=$(echo $INFO | awk -F "$DS" -v j=$i '{print $j}')
    if echo $GROUP | grep -v '<none>' | grep 'Running' >/dev/null 2>&1; then
      N2=$[$N2+1]
    fi
  done
  if [[ "$N2" == "$N" ]]; then 
    echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [INFO] - $DS started."
    exit 0
  else
    sleep $SLEEP
  fi
done
echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - $DS failed !!!"
exit 1

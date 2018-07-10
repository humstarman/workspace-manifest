#!/bin/bash
set -e
# 0 set env
DEFAULT_NUM=7
DEFAULT_CAPACITY=100
show_help () {
cat << USAGE
usage: $0 [ -g GLUSTERFS-IMAGE ] [ -n NUMBER-OF-LOOP-DEVICE ] [ -v VIRTUAL-DISK-CAPACITY ]
    -i : Specify the IP address(es) of the host(s), if multiple, set in term of csv.
    -n : Specify the number of device /dev/loop. If not specified, use '${DEFAULT_NUM}' by default. 
    -v : Specify the capacity of each virtual disk, in term of Gi. If not specified, use '${DEFAULT_CAPACITY}' Gi by default. 
USAGE
exit 0
}
# Get Opts
while getopts "hg:n:c:" opt; do # 选项后面的冒号表示该选项需要参数
    case "$opt" in
    h)  show_help
        ;;
    g)  GLUSTERFS_IMG=$OPTARG
        ;;
    n)  NUM=$OPTARG
        ;;
    c)  CAPACITY=$OPTARG
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
chk_var -g $GLUSTERFS_IMG
DIR=${GLUSTERFS_IMG%/*}
#echo $DIR
#mkdir -p $DIR
#[ -f $GLUSTERFS_IMG ] && rm -f $GLUSTERFS_IMG 
NUM=${NUM:-"${DEFAULT_NUM}"}
CAPACITY=${CAPACITY:-"${DEFAULT_CAPACITY}"}
DEV=/dev/loop${NUM}
#echo $VER
#echo $NUM
# 1 install glusterfs client
if [ -x "$(command -v yum)" ]; then
  yum makecache fast
  yum install -y glusterfs-client
elif [ -x "$(command -v apt-get)" ]; then
  apt-get update
  apt install -y glusterfs-client
else
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - unknown Distributor ID."
  exit 1
fi
# 2 load kernel mod
NAME=glusterfs-mod
## 2.1 binary file
BIN=/usr/local/bin/${NAME}.sh
cat > $FILE <<"EOF"
#!/bin/bash
MODULES="dm_snapshot dm_mirror dm_thin_pool"
for MODULE in $MODULES; do
  modprobe $MODULE
done
for MODULE in $MODULES; do
  lsmod | grep $MODULE
done
iptables -I INPUT -p tcp --dport 24007 -j ACCEPT
iptables -N heketi
iptables -A heketi -p tcp -m state --state NEW -m tcp --dport 24007 -j ACCEPT
iptables -A heketi -p tcp -m state --state NEW -m tcp --dport 24008 -j ACCEPT
iptables -A heketi -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
iptables -A heketi -p tcp -m state --state NEW -m multiport --dports 49152:49251 -j ACCEPT
EOF
mod +x ${BIN}
## 2.2 service file
SVC=${NAME}.service
cat > /etc/systemd/system/$SVC <<EOF
[Unit]
Description=Switch-on Kernel Modules Needed by Glusterfs

[Service]
Type=oneshot
ExecStart=${BIN}

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable $SVC
systemctl restart $SVC
# 3 generate virtual disk
dd if=/dev/zero of=${GLUSTERFS_IMG} bs=1M count=$[${CAPACITY}*1000]
losetup $DEV $GLUSTERFS_IMG 
pvcreate -y $DEV
exit 0

#!/bin/bash

set -e

source /etc/profile

# check Kubernetes DNS
if [ ! -x "$(command -v kubectl)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no kubectl installed!"
  sleep 3
  exit 1
fi
if [ -z "$(kubectl -n kube-system get po | grep dns | grep Running)" ]; then
  echo "$(date -d today +'%Y-%m-%d %H:%M:%S') - [ERROR] - no running DNS pod on Kubernetes!"
  sleep 3
  exit 1
fi

DNS="/etc/resolv.conf"
ORIGINAL_DNS1="100.100.2.136"
ORIGINAL_DNS2="100.100.2.138"

cat > $DNS << EOF
nameserver 127.0.0.1
nameserver ${THIS_IP}
nameserver 10.254.0.2
search default.svc.cluster.local. svc.cluster.local. cluster.local.
options ndots:5
nameserver ${ORIGINAL_DNS1}
nameserver ${ORIGINAL_DNS2}
EOF

# mk a script
if [ ! -x "/usr/local/bin/dns-shared.sh" ]; then
  cat > /usr/local/bin/dns-shared.sh << EOF
#!/bin/bash

source /etc/profile

DNS="/etc/resolv.conf"
ORIGINAL_DNS1=$ORIGINAL_DNS1
ORIGINAL_DNS2=$ORIGINAL_DNS2

cat > \$DNS << EOF
nameserver 127.0.0.1
nameserver \${THIS_IP}
nameserver 10.254.0.2
search default.svc.cluster.local. svc.cluster.local. cluster.local.
options ndots:5
nameserver \${ORIGINAL_DNS1}
nameserver \${ORIGINAL_DNS2}
{{.placeholder}}EOF
EOF
  sed -i s/"{{.placeholder}}"//g /usr/local/bin/dns-shared.sh
  chmod +x /usr/local/bin/dns-shared.sh
fi

if [ ! -f "/etc/systemd/system/dns-shared.service" ]; then
  cat > /etc/systemd/system/dns-shared.service << EOF
[Unit]
Description=Oneshot App

[Service]
Type=oneshot
ExecStart=/bin/sh \\
          -c \\
          "sleep 60 && /usr/local/bin/dns-shared.sh"

[Install]
WantedBy=multi-user.target
EOF
fi

systemctl daemon-reload
systemctl enable dns-shared.service
systemctl restart dns-shared.service

FROM centos:systemd
RUN yum makecache fast
RUN yum install -y bind-libs bind-utils bind.x86_64
RUN yum clean all
ADD ./scripts/entrypoint.sh /
ADD ./scripts/dns.service /etc/systemd/system/
RUN systemctl enable dns
CMD ["/usr/sbin/init"]

FROM 10.254.0.50:5000/centos:systemd
RUN yum makecache fast
RUN yum install -y bind-libs bind-utils bind.x86_64
RUN yum clean all
CMD ["/usr/sbin/init"]

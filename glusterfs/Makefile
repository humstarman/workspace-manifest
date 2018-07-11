GROUP=glusterfs
HOSTS=192.168.100.164,192.168.100.165,192.168.100.166
GLUSTERFS_IMG=/opt/glsuterfs/glusterfs.img
MASTER=`cat /var/k8s/bak/master.csv`

check:
	@./scripts/mk-ansible-hosts.sh -g ${GROUP} -i ${HOSTS} -o
	@ansible ${GROUP} -m ping

test:
	@echo ${MASTER}

install:
	@ansible ${GROUP} -m script -a "./scripts/prepare-4-glusterfs.sh -g ${GLUSTERFS_IMG}"

dev:
	./scripts/prepare-4-glusterfs.sh -g ${GLUSTERFS_IMG}

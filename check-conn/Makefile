IMAGE_NAME=busybox
TAG=latest
DS_SUFFIX=ds

IMAGE=$(IMAGE_NAME):$(TAG)
DS=$(IMAGE_NAME)-$(DS_SUFFIX)

build:
	@yes | cp ./daemonset.yaml.sed ./daemonset.yaml
	@sed -i s?"{{.image}}"?"$(IMAGE)"?g daemonset.yaml
	@sed -i s?"{{.ds}}"?"$(DS)"?g daemonset.yaml

deploy:
	@kubectl create -f ./daemonset.yaml

run:
	@./check-conn.sh -d $(DS)

check:
	@./wait-for.sh -d $(DS)

clean:
	@kubectl delete -f ./daemonset.yaml
	@rm -f ./daemonset.yaml

all: build deploy check run clean

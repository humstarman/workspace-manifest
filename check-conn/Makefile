IMAGE_NAME=busybox
TAG=latest
DS_SUFFIX=ds

IMAGE=$(IMAGE_NAME):$(TAG)
DS=$(IMAGE_NAME)-$(DS_SUFFIX)

build:
	@yes | cp ./manifest/daemonset.yaml.sed ./manifest/daemonset.yaml
	@sed -i s?"{{.image}}"?"$(IMAGE)"?g ./manifest/daemonset.yaml
	@sed -i s?"{{.ds}}"?"$(DS)"?g ./manifest/daemonset.yaml

deploy:
	@kubectl create -f ./manifest/daemonset.yaml

run:
	@./scripts/check-conn.sh -d $(DS)

check:
	@./scripts/wait-for.sh -d $(DS)

clean:
	@kubectl delete -f ./manifest/daemonset.yaml
	@rm -f ./manifest/daemonset.yaml

all: build deploy check run clean

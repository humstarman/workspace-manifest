IMAGE_NAME=haproxy
TAG=latest
NAMESPACE=filtre

LOCAL_REGISTRY=gmt.reg.me/test
IMAGE=$(LOCAL_REGISTRY)/$(IMAGE_NAME):$(TAG)

all: build push deploy

build:
	@docker build -t $(IMAGE) .

push:
	@docker push $(IMAGE)

pull:
	-@ansible master -m shell -a "docker pull $(IMAGE)"
	-@ansible node -m shell -a "docker pull $(IMAGE)"

cp:
	@yes | cp ./manifest/daemonset.yaml.sed ./manifest/daemonset.yaml

sed:
	@sed -i s?"{{.image}}"?"$(IMAGE)"?g ./manifest/daemonset.yaml 

deploy: cp sed
	-@kubectl create -f ./manifest/namespace.yaml
	@kubectl create -f ./manifest/configmap.yaml
	@kubectl create -f ./manifest/daemonset.yaml

test:
	@kubectl -n ${NAMESPACE} get po 

clean:
	@kubectl delete -f ./manifest/namespace.yaml

refresh:
	-@kubectl delete -f ./manifest/configmap.yaml
	@kubectl create -f ./manifest/configmap.yaml

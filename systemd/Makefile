LOCAL_REGISTRY_IP=10.254.0.50
LOCAL_REGISTRY_PORT=5000
PROJECT=centos
TAG=systemd

LOCAL_REGISTRY=${LOCAL_REGISTRY_IP}:${LOCAL_REGISTRY_PORT}
IMAGE=${LOCAL_REGISTRY}/${PROJECT}:${TAG}
NAME=systemd
PORT=53
CONTAINER=systemd

build:
	@docker build -t ${IMAGE} .

push:
	@docker push ${IMAGE}

all : build push cp sed deploy

run:
	@docker run -d --name ${CONTAINER} --hostname ${CONTAINER} --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --privileged ${IMAGE}

clean_d:
	@docker stop ${CONTAINER}
	@docker rm ${CONTAINER}

cp:
	@find ./manifest -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.port}}"?"${PORT}"?g 
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.image}}"?"${IMAGE}"?g

deploy:
	@kubectl create -f ./manifest/.

clean:
	@kubectl delete -f ./manifest/.
	@find ./manifest/deploy -type f -name "*.yaml" | xargs rm -f


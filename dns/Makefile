LOCAL_REGISTRY_IP=10.254.0.50
LOCAL_REGISTRY_PORT=5000
NAME=dns
NAMESPACE=default
#NAMESPACE=${NAME}
TAG=v1
GROUP=k8s

PROJECT=${NAME}
LOCAL_REGISTRY=${LOCAL_REGISTRY_IP}:${LOCAL_REGISTRY_PORT}
IMAGE=${LOCAL_REGISTRY}/${PROJECT}:${TAG}
CONTAINER=${NAME}
PORT=53
CLUSTER_IP=10.254.0.53
LOCAL_IMAGE=${PROJECT}:${TAG}

all : build push pull deploy

dns-cp:
	@yes | cp ./scripts/dns.service.sed ./scripts/dns.service

dns-sed:
	@sed -i s?"workspace/"?""?g ./scripts/dns.service

build-d: export IMAGE=${LOCAL_IMAGE}
build-d: dns-cp dns-sed
	@docker build -t ${IMAGE} .

build: dns-cp
	@docker build -t ${IMAGE} .

push:
	@docker push ${IMAGE}

pull:
	@ansible ${GROUP} -m shell -a "docker pull ${IMAGE}"

run: build-d
	@docker run -d --publish 53:53/tcp --publish 53:53/udp --restart=always --name ${CONTAINER} --hostname ${CONTAINER} --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --privileged ${IMAGE}

clean-d:
	@docker stop ${CONTAINER}
	@docker rm ${CONTAINER}

cp:
	@find ./manifest -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.port}}"?"${PORT}"?g 
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.image}}"?"${IMAGE}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.cluster.ip}}"?"${CLUSTER_IP}"?g

check:
	@[ -z ${NAMESPACE} ] || ./scripts/chk-ns.sh -s ${NAMESPACE} 

deploy: check cp sed
	@kubectl create -f ./manifest/.

clean:
	@kubectl delete -f ./manifest/.
	@find ./manifest -type f -name "*.yaml" | xargs rm -f

func:
	@kubectl exec -it `./scripts/get-pod-name.sh -n ${NAME} -s ${NAMESPACE}` /workspace/entrypoint.sh

refresh:
	@./scripts/refresh-entrypoint.sh -p sh2cm

test: export IMAGE=${LOCAL_IMAGE}
test: 
	@yes | cp ./scripts/dns.service.sed ./scripts/dns.service
	@sed -i s?"workspace/"?""?g ./scripts/dns.service
	@echo ${IMAGE}

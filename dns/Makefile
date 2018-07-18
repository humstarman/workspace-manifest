LOCAL_REGISTRY_IP=10.254.0.50
LOCAL_REGISTRY_PORT=5000
NAME=dns
NAMESPACE=default
TAG=v1
GROUP=k8s

PROJECT=${NAME}
LOCAL_REGISTRY=${LOCAL_REGISTRY_IP}:${LOCAL_REGISTRY_PORT}
IMAGE=${LOCAL_REGISTRY}/${PROJECT}:${TAG}
CONTAINER=${NAME}
PORT=53
CLUSTER_IP=10.254.0.53

build:
	@docker build -t ${IMAGE} .

push:
	@docker push ${IMAGE}

pull:
	@ansible ${GROUP} -m shell -a "docker pull ${IMAGE}"

all : build push pull cp sed deploy

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
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.cluster.ip}}"?"${CLUSTER_IP}"?g

apply:
	@kubectl create -f ./manifest/.

deploy: cp sed apply

clean:
	@kubectl delete -f ./manifest/.
	@find ./manifest -type f -name "*.yaml" | xargs rm -f

func:
	@kubectl exec -it `./scripts/get-pod-name.sh -n ${NAME} -s ${NAMESPACE}` /workspace/entrypoint.sh

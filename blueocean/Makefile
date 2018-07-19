LOCAL_REGISTRY="10.254.0.50:5000"
IMAGE_NAME="blueocean"
IMAGE_TAG="v1"
ANSIBLE_GROUP="all"
KUBE_API_SECURE_PORT="6443"
KUBE_API_INSECURE_PORT="8080"
KUBECTL_BINARY_PATH="/usr/local/bin/kubectl"
KUBECTL_CONFIG_PATH="/root/.kube"
NAME="blueocean"
NAMESPACE="gitlab"
HA_METHOD="vip"
#HA_METHOD="nigix"
PV="false"
#PV:="true"
PV_METHOD="nfs"
PV_CAPACITY="10"
OUTPUT="./manifest/controller.yaml.sed"
URL="gmt.blue.me"

IMAGE=${LOCAL_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
ARGS="-a ${HA_METHOD} -o ${OUTPUT}"
ifeq (${PV},"true")
ARGS+=" -p -m ${PV_METHOD} -c ${PV_CAPACITY}"
endif
ifeq (${HA_METHOD},"nginx")
MASTER_IP_1=1
MASTER_IP_2=2
MASTER_IP_3=3
endif

test:
all: build push pull deploy

ifeq (${PV},"true")
	@echo ${ARGS}
else
	@echo ${ARGS}
endif

build:
	@docker build -t ${IMAGE} .

push:
	@docker push ${IMAGE}

pull:
	-@ansible ${ANSIBLE_GROUP} -m shell -a "docker pull ${IMAGE}"

cp:
	@./scripts/mk-template.sh "${ARGS}"
	@find ./manifest -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.url}}"?"${URL}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.cluster.ip}}"?"${CLUSTER_IP}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.master.ip.1}}"?"${MASTER_IP_1}"?g 
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.master.ip.2}}"?"${MASTER_IP_2}"?g 
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.master.ip.3}}"?"${MASTER_IP_3}"?g 
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.kube-apiserver.secure.port}}"?"${KUBE_API_SECURE_PORT}"?g 
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.kube-apiserver.insecure.port}}"?"${KUBE_API_INSECURE_PORT}"?g 
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.image}}"?"${IMAGE}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.kubectl.binary.path}}"?"${KUBECTL_BINARY_PATH}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.kubectl.config.path}}"?"${KUBECTL_CONFIG_PATH}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.pv.capacity}}"?"${PV_CAPACITY}"?g

deploy: cp sed 
	-@kubectl create -f ./manifest/namespace.yaml
	-@kubectl create -f ./manifest/deploy/service.yaml
ifeq (${HA_METHOD},"nginx")
	-@kubectl create -f ./manifest/deploy/configmap.yaml
endif
	@kubectl create -f ./manifest/deploy/controller.yaml

clean:
	-@kubectl delete -f ./manifest/deploy/.
	@find ./manifest/deploy -type f -name "*.yaml" | xargs rm -f

refresh:
	@kubectl delete -f ./manifest/configmap.yaml
	@kubectl create -f ./manifest/configmap.yaml


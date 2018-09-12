SHELL=/bin/bash
NAME=cli
NAMESPACE=default
IMAGE=centos:7
IMAGE_PULL_POLICY=IfNotPresent
MANIFEST=./manifest
SCRIPT=./scripts

all: deploy 

cp:
	@find ${MANIFEST} -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image}}"?"${IMAGE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image.pull.policy}}"?"${IMAGE_PULL_POLICY}"?g

deploy: OP=create 
deploy: cp sed
	@kubectl ${OP} -f ${MANIFEST}/controller.yaml

clean: OP=delete
clean:
	@kubectl ${OP} -f ${MANIFEST}/controller.yaml
	@rm -f ${MANIFEST}/controller.yaml

cli: export POD_NAME=`${SCRIPT}/get-pod-name.sh -n ^${NAME} -s ${NAMESPACE}`
cli:
	@kubectl exec -it ${POD_NAME} -- /bin/bash

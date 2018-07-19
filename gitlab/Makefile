NAMESPACE=gitlab
NAME=gitlab
URL="gmt.gitlab.me"

CLUSTER_IP="10.254.0.22"
IMAGE_GITLAB=gitlab/gitlab-ce:11.0.1-ce.0
IMAGE_POSTGRES=postgres:9.6.2-alpine
IMAGE_REDIS=redis:3.0.7-alpine

all: deploy

cp:
	@find ./manifest -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.url}}"?"${URL}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.cluster.ip}}"?"${CLUSTER_IP}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.image.gitlab}}"?"${IMAGE_GITLAB}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.image.postgres}}"?"${IMAGE_POSTGRES}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.image.redis}}"?"${IMAGE_REDIS}"?g

deploy: cp sed
	-@kubectl create -f ./manifest/namespace.yaml
	-@kubectl create -f ./manifest/rbac.yaml
	@kubectl create -f ./manifest/gitlab/.

test: 
	@find ./ -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

clean:
	@kubectl delete -f ./manifest/gitlab/.
	@find ./manifest/gitlab -type f -name "*.yaml" | xargs rm -f 

dryrun: cp sed

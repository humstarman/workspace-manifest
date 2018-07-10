LOCAL_REGISTRY=192.168.100.167:5000
NAME=file-server
TAG=lastet
SHARED=/opt/app
PORT=2121
TARGET_NODE=192.168.100.166

TEST=test.log
IMAGE=$(LOCAL_REGISTRY)/$(NAME):$(TAG)
SERVICE_IP=10.254.0.21
SELECTOR=fileserver

build:
	@docker build -t $(LOCAL_REGISTRY)/$(NAME):$(TAG) .

push:
	@docker push $(LOCAL_REGISTRY)/$(NAME):$(TAG)

pull:
	-@ansible $(TARGET_NODE) -m shell -a "docker pull $(LOCAL_REGISTRY)/$(NAME):$(TAG)"

run:
	@docker run -d --network host -v $(SHARED):/mnt --name $(NAME) $(LOCAL_REGISTRY)/$(NAME):$(TAG) /file-server -p=$(PORT)

sed:
	@yes | cp ./manifest/controller.yaml.sed ./manifest/controller.yaml
	@yes | cp ./manifest/service.yaml.sed ./manifest/service.yaml
	@sed -i s?"{{.name}}"?"$(NAME)"?g ./manifest/controller.yaml
	@sed -i s?"{{.image}}"?"$(IMAGE)"?g ./manifest/controller.yaml
	@sed -i s?"{{.shared}}"?"$(SHARED)"?g ./manifest/controller.yaml
	@sed -i s?"{{.selector}}"?"$(SELECTOR)"?g ./manifest/controller.yaml
	@sed -i s?"{{.name}}"?"$(NAME)"?g ./manifest/service.yaml
	@sed -i s?"{{.service.ip}}"?"$(SERVICE_IP)"?g ./manifest/service.yaml

deploy:
	-@kubectl label node $(TARGET_NODE) $(SELECTOR)=true
	-@kubectl label node $(TARGET_NODE) $(SELECTOR)=true --overwrite
	@kubectl create -f ./manifest/service.yaml
	@kubectl create -f ./manifest/controller.yaml

clean:
	-@kubectl label node $(TARGET_NODE) $(SELECTOR)=false --overwrite
	@kubectl delete -f ./manifest/service.yaml
	@kubectl delete -f ./manifest/controller.yaml
	@rm -f ./manifest/controller.yaml
	@rm -f ./manifest/service.yaml

oldclean:
	@docker stop $(NAME) && docker rm $(NAME)

all: build push pull sed deploy 

oldtest:
	@[ -f $(SHARED)/$(TEST) ] || touch $(SHARED)/$(TEST)
	@echo "Test Successd" > $(SHARED)/$(TEST)
	@curl -s http://127.0.0.1:$(PORT)/$(TEST) 

test:
	@ ansible $(TARGET_NODE) -m shell -a "[ -f $(SHARED)/$(TEST) ] || touch $(SHARED)/$(TEST); echo 'Test Successd' > $(SHARED)/$(TEST)"
	@curl -s http://$(SERVICE_IP)/$(TEST) 

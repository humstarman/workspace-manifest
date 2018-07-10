LOCAL_REGISTRY=192.168.100.167:5000
NAME=file-server
TAG=lastet
SHARED=/opt/app
PORT=2121
TEST=test.log

build:
	@docker build -t $(LOCAL_REGISTRY)/$(NAME):$(TAG) .

push:
	@docker push $(LOCAL_REGISTRY)/$(NAME):$(TAG)

pull:
	-@ansible all -m shell -a "docker pull $(LOCAL_REGISTRY)/$(NAME):$(TAG)"

run:
	@docker run -d --network host -v $(SHARED):/mnt --name $(NAME) $(LOCAL_REGISTRY)/$(NAME):$(TAG) /file-server -p=$(PORT)

clean:
	@docker stop $(NAME) && docker rm $(NAME)

all: build push pull run

test:
	@[ -f $(SHARED)/$(TEST) ] || touch $(SHARED)/$(TEST)
	@echo "Test Successd" > $(SHARED)/$(TEST)
	@curl -s http://127.0.0.1:$(PORT)/$(TEST) 

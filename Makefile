
.DEFAULT_GOAL = docker

.PHONY: docker ecr-login ecr-publish
#
# The following assumes that the ECR repository has been created
APP_BINARY := main
GO_BINARY := go1.12.1.linux-amd64.tar.gz
GO_URL := https://dl.google.com/go/$(GO_BIN)
REPO_NAME := production/simple-webapp
DOCKER_CMD := $(shell aws ecr get-login | sed -e "s/-e none//g")
DOCKER_URI := $(shell aws ecr describe-repositories --query 'repositories[?repositoryName==`$(REPO_NAME)`].repositoryUri' --output text)


$(APP_BINARY): main.go
	go build $<

$(GO_BINARY):
	wget $(GO_URL)	

docker:  $(APP_BINARY) go1.12.1.linux-amd64.tar.gz
	docker build --build-arg go_binary=$(GO_BINARY) -t $(REPO_NAME) .

ecr-login:
	$(DOCKER_CMD)
	@echo "Logged into $(DOCKER_URI)"

ecr-deploy: docker ecr-login
	docker tag $(REPO_NAME):latest $(DOCKER_URI):latest
	docker push $(DOCKER_URI):latest

help:
	@echo "make docker: create a docker image"
	@echo "make ecr-deploy: deploy the image to AWS ECR"


.DEFAULT_GOAL = docker

.PHONY: docker ecr-login ecr-publish help
#
# The following assumes that the ECR repository has been created
APP_BINARY := main
GO_BINARY := go1.12.1.linux-amd64.tar.gz
GO_URL := https://dl.google.com/go/$(GO_BIN)
REPO_NAME := production/simple-webapp
DOCKER_CMD := $(shell aws ecr get-login | sed -e "s/-e none//g")
DOCKER_URI := $(shell aws ecr describe-repositories --query 'repositories[?repositoryName==`$(REPO_NAME)`].repositoryUri' --output text)


# Build the simple webapp
$(APP_BINARY): main.go
	go build $<

# Download the Golang compiler
$(GO_BINARY):
	wget $(GO_URL)	

## docker: Build the docker image
docker:  $(APP_BINARY) go1.12.1.linux-amd64.tar.gz
	docker build --build-arg go_binary=$(GO_BINARY) -t $(REPO_NAME) .

# log in to AWS ECR
ecr-login:
	$(DOCKER_CMD)
	@echo "Logged into $(DOCKER_URI)"

## ecr-deploy: Deploy the Docker image to AWS ECR
ecr-deploy: docker ecr-login
	docker tag $(REPO_NAME):latest $(DOCKER_URI):latest
	docker push $(DOCKER_URI):latest

help: Makefile
	@sed -n 's/^##//p' $<

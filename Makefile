PHONY.: all build push build-and-push build-public push-public build-and-push-public

makeFileDir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ifndef DOCKER_REGISTRY
	DOCKER_REGISTRY := docker-registry.liny.io
endif
ifndef DOCKER_CONTAINER_NAME
	DOCKER_CONTAINER_NAME := linyio/ovpn
endif
ifndef DOCKER_IMAGE_TAG
	DOCKER_IMAGE_TAG := latest
endif
ifndef DOCKER_PATH
	DOCKER_PATH := $(makeFileDir)
endif

DOCKER_IMAGE_NAME = $(DOCKER_REGISTRY)/$(DOCKER_CONTAINER_NAME):$(DOCKER_IMAGE_TAG)
DOCKER_IMAGE_PUBLIC_NAME = $(DOCKER_CONTAINER_NAME):$(DOCKER_IMAGE_TAG)
all: build push

build:
	docker build --pull -t $(DOCKER_IMAGE_NAME) $(DOCKER_PATH)

build-public:
	docker build --pull -t $(DOCKER_IMAGE_PUBLIC_NAME) $(DOCKER_PATH)


push:
	docker push $(DOCKER_IMAGE_NAME)

push-public:
	docker push $(DOCKER_IMAGE_PUBLIC_NAME)

build-and-push: build push

build-and-push-public: build-public push-public

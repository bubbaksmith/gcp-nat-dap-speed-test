# Container settings
IMG ?= nat-test:demo
CONTAINER_TOOL ?= docker
DOCKERHUB_ACCOUNT ?= l3rl4n

# K8s settings
NAMESPACE ?= default
CLUSTER_NAME ?= autopilot-cluster-2
KUBECTL ?= kubectl --context ${CLUSTER_NAME} -n ${NAMESPACE}


.PHONY: deploy
deploy:
	$(KUBECTL) apply -f ./k8s

.PHONY: build
build:
	$(CONTAINER_TOOL) build . -t $(DOCKERHUB_ACCOUNT)/$(IMG)

.PHONY: push
push:
	$(CONTAINER_TOOL) push $(DOCKERHUB_ACCOUNT)/$(IMG)

.PHONY: trigger
trigger:
	$(KUBECTL) create job --from=cronjob/nat-test nat-test


# Container settings
IMG ?= nat-test:demo
CONTAINER_TOOL ?= docker
DOCKERHUB_ACCOUNT ?= l3rl4n

# K8s settings
NAMESPACE ?= default
CLUSTER_NAME ?= cluster-1
KUBECTL ?= kubectl --context ${CLUSTER_NAME} -n ${NAMESPACE}


.PHONY: deploy
deploy:
	$(KUBECTL) apply -f ./k8s

.PHONY: build
build:
	$(CONTAINER_TOOL) build . -t $(DOCKERHUB_ACCOUNT)/$(IMG) --platform=linux/amd64

.PHONY: push
push:
	$(CONTAINER_TOOL) push $(DOCKERHUB_ACCOUNT)/$(IMG)

.PHONY: trigger
trigger:
	$(KUBECTL) delete pods -l app=nat-test
	$(KUBECTL) create job --from=cronjob/nat-test nat-test-$(shell uuidgen | tr "[:upper:]" "[:lower:]" | cut -d"-" -f2)
	stern nat-test

.PHONY: describe
describe:
	$(KUBECTL) describe pod "$(shell kubectl get pods -l job-name=nat-test --no-headers | cut -d" " -f1)"

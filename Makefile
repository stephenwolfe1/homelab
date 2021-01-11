## Global Config ##
ENV         ?= local
SHELL       := /bin/bash
SHA         ?= $(shell git rev-parse HEAD)
EXECUTABLES  = helm kubectl yq

ifndef CIRCLE_PROJECT_REPONAME
# Check for required EXECUTABLES
CHECK := $(foreach exec,$(EXECUTABLES),\
	$(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))
endif

ifneq "${OVERRIDE_SERVICES}" ""
	override HELM_SERVICES := ${OVERRIDE_SERVICES}
	override K8S_SERVICES  := ${OVERRIDE_SERVICES}
endif
## Global Config ##

## Helm Config ##
HELM_BASE         := services/helm
HELM_SERVICES     := $(shell git show --name-only --oneline ${SHA} | grep ${HELM_BASE} | cut -d/ -f3 | sort -u)
ALL_HELM_SERVICES := $(shell for service in $(sort $(wildcard ./${HELM_BASE}/*)); do echo $$service | cut -d/ -f4 | tr "\n" " "; done)

override HELM_SERVICES := $(filter $(ALL_HELM_SERVICES), $(HELM_SERVICES))

METADATA := chartname=$$(yq read ${HELM_BASE}/$${SERVICE}/values.yaml metadata.chartname) \
	releaseName=$$(yq read ${HELM_BASE}/$${SERVICE}/values.yaml metadata.release.name) \
	releaseNamespace=$$(yq read ${HELM_BASE}/$${SERVICE}/values.yaml metadata.release.namespace)

.PHONY: helm-services
helm-services: ## display helm services that will be run
	@echo ${HELM_SERVICES}
## Helm Config ##

## K8S Config ##
K8S_BASE         := services/k8s
K8S_SERVICES     := $(shell git show --name-only --oneline ${SHA} | grep ${K8S_BASE} | cut -d/ -f3 | sort -u)
ALL_K8S_SERVICES := $(shell for service in $(sort $(wildcard ./${K8S_BASE}/*)); do echo $$service | cut -d/ -f4 | tr "\n" " "; done)

override K8S_SERVICES := $(filter $(ALL_K8S_SERVICES), $(K8S_SERVICES))

.PHONY: k8s-services
k8s-services: ## display k8s services that will be run
	@echo ${K8S_SERVICES}
## K8S Config ##

## Main commands ##
.PHONY: all-services
all-services: ## display all services
	@echo -e "\n\tAll Helm Services: ${ALL_HELM_SERVICES}\n\tAll K8S Services: ${ALL_K8S_SERVICES}\n"

.PHONY: services
services: ## display services to be run
	@echo -e "\n\tHelm Services: ${HELM_SERVICES}\n\tK8S Services: ${K8S_SERVICES}\n"

<<<<<<< HEAD
=======
.PHONY: template
template: ## runs install on ${HELM_SERVICES} and ${K8S_SERVICES}
	@set -e; \
	mkdir -p templates; \
	for SERVICE in ${HELM_SERVICES}; do \
		echo "*********************************************************************************"; \
		echo "  Running helm template for contents of ${HELM_BASE}/$$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
		${METADATA}; \
		helm template $${releaseName} $${chartname} -f ${HELM_BASE}/$$SERVICE/values.yaml --namespace $${releaseNamespace} --output-dir ./templates; \
		echo -e "\n\n\n*********************************************************************************"; \
		echo "  Finished running helm install for $$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
	done;

>>>>>>> Initial kube service setup
.PHONY: install
install: ## runs install on ${HELM_SERVICES} and ${K8S_SERVICES}
	@set -e; \
	for SERVICE in ${HELM_SERVICES}; do \
		echo "*********************************************************************************"; \
		echo "  Running helm install for contents of ${HELM_BASE}/$$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
		${METADATA}; \
		helm upgrade $${releaseName} $${chartname} --install -f ${HELM_BASE}/$$SERVICE/values.yaml --namespace $${releaseNamespace}; \
		echo -e "\n\n\n*********************************************************************************"; \
		echo "  Finished running helm install for $$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
	done; \
	for SERVICE in ${K8S_SERVICES}; do \
		echo "*********************************************************************************"; \
		echo "  Running kubectl apply for contents of ${K8S_BASE}/$$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
		kubectl apply -f ${K8S_BASE}/$$SERVICE/; \
		echo -e "\n\n\n*********************************************************************************"; \
		echo "  Finished running kubectl apply for $$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
	done;

.PHONY: delete
delete: ## runs helm delete on ${HELM_SERVICES} and ${K8S_SERVICES}
	@set -e; \
	for SERVICE in ${HELM_SERVICES}; do \
		echo "*********************************************************************************"; \
		echo "  Running helm delete for contents of ${HELM_BASE}/$$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
		${METADATA}; \
		helm delete $${releaseName} --namespace $${releaseNamespace}; \
		echo -e "\n\n\n*********************************************************************************"; \
		echo "  Finished running helm delete for $$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
	done; \
	for SERVICE in ${K8S_SERVICES}; do \
		echo "*********************************************************************************"; \
		echo "  Running kubectl delete for contents of ${K8S_BASE}/$$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
<<<<<<< HEAD
		${METADATA}; \
		helm delete $${releaseName} --namespace $${releaseNamespace}; \
=======
		kubectl delete -f ${K8S_BASE}/$$SERVICE/; \
>>>>>>> Initial kube service setup
		echo -e "\n\n\n*********************************************************************************"; \
		echo "  Finished running kubectl delete for $$SERVICE"; \
		echo -e "*********************************************************************************\n\n\n"; \
	done;

.PHONY: help
help: ## show this usage
	@echo -e "\033[36mHomelab Services:\033[0m\nUsage: [OVERRIDE_SERVICES=\$${services}] make [target]\n"; \
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

## homelab
This repo manages the setup for a Raspberry Pi backed homelab

## Table of contents

<!--ts-->

* [Table of contents](#table-of-contents)
* [Overview](#overview)
* [Services Folder Structure](#services-folder-structure)
* [Services CI Logic](#services-ci-logic)
* [Makefile Usage](#makefile-usage)

<!--te-->

## Overview
Contains scripts for bootstrapping and managing a Raspberry Pi Kubernetes Cluster. Services folder contains base infrastructure services for setting up things like ingress and DNS.

## Services Folder Structure
* _services/helm_ contains values.yaml for any Helm chart to install. Each values.yaml should contain a _metadata_ block that will define the chart name, release name, and release namespace. Example:
```yaml
metadata:
  chartname: jetstack/cert-manager
  release:
    name: cert-manager
    namespace: kube-system
```
* _services/k8s_ contains any native Kubernetes files to install

## Services CI Logic
The Makefile will determine which _${SERVICES}_ to run base on the git log. For this to work correctly with CI, Merge Commits must be disabled in Github for repo and the last commit must contain the changes for any desired services to be run. For local apply or testing this can be overwritten with _${OVERRIDE_SERVICES}_. _make services_ will always show you what services will be run. Examples:
```bash
make services
make install

 or

OVERRIDE_SERVICES=test make services
OVERRIDE_SERVICES=test make install

 or

OVERRIDE_SERVICES="cert-manager metallb test" make services
```

## Makefile Usage
```bash
Homelab Services:
Usage: [OVERRIDE_SERVICES=${services}] make [target]

helm-services                  display helm services that will be run
k8s-services                   display k8s services that will be run
all-services                   display all services
services                       display services to be run
install                        runs install on ${HELM_SERVICES} and ${K8S_SERVICES}
delete                         runs helm delete on ${HELM_SERVICES} and ${K8S_SERVICES}
help                           show this usage
```

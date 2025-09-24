IMAGE_NAME := "crispyduck/cert-manager-webhook-cloudns"
IMAGE_TAG := "1.2.1"
RELEASE_NAMESPACE := "cloudns-webhook"

OUT := $(shell pwd)/.out

$(shell mkdir -p "$(OUT)")

verify:
	TEST_ASSET_ETCD=$(OUT)/kubebuilder/bin/etcd \
	TEST_ASSET_KUBE_APISERVER=$(OUT)/kubebuilder/bin/kube-apiserver \
	TEST_ASSET_KUBECTL=$(OUT)/kubebuilder/bin/kubectl \
	go test -v .

build:
	docker build -t "$(IMAGE_NAME):$(IMAGE_TAG)" .

push:
	docker push "$(IMAGE_NAME):$(IMAGE_TAG)" .

.PHONY: rendered-manifest.yaml
rendered-manifest.yaml:
	helm template \
		--name-template cert-manager-webhook-cloudns \
		--set image.repository=$(IMAGE_NAME) \
		--set image.tag=$(IMAGE_TAG) \
		-n $(RELEASE_NAMESPACE) \
		deploy/cert-manager-webhook-cloudns > "$(OUT)/rendered-manifest.yaml"

NAMESPACE=my-nginx
IMAGE_NAME=my-nginx:latest
IMAGE_NAME_DEV=my-nginx:dev
MANIFEST_FILE=manifests/deploy.tpl.yaml
IMAGE_PULL_POLICY=Always

KUBECTL_ROLLOUT_RESOURCE=deployment/my-nginx
KUBECTL_ROLLOUT_TIMEOUT=20s

ACCESS_SVC_NAME=svc/my-nginx
ACCESS_SVC_PORT=8000:80
ACCESS_POD_NAME=my-nginx
ACCESS_SHELL=bash

help:
	@echo "Available make operations are:"
	@echo
	@echo "    run [NAMESPACE=${NAMESPACE}] [IMAGE_NAME_DEV=${IMAGE_NAME_DEV}]"
	@echo "    builds a dev image, deploys it, does port forward, and opens a shell"
	@echo "    the service is accessible over port ACCESS_SVC_PORT=${ACCESS_SVC_PORT}"
	@echo "    closing the shell terminates the port forwad and shell before deleting deployment"

	@echo
	@echo "    build [NAMESPACE=${NAMESPACE}] [IMAGE_NAME=${IMAGE_NAME}]"
	@echo "    builds the container image and manifest"

	@echo
	@echo "    shell [NAMESPACE=${NAMESPACE}]"
	@echo "    opens shell to running deployment"

	@echo
	@echo "    access [NAMESPACE=${NAMESPACE}]"
	@echo "    does port forward to the service and opens shell to running deployment"
	@echo "    the service is accessible over port ACCESS_SVC_PORT=${ACCESS_SVC_PORT}"
	@echo "    closing the shell terminates both"

	@echo
	@echo "    clean"
	@echo "    does artifact cleanup"

run:
	# build the container image
	docker build -t "${IMAGE_NAME_DEV}" .

	# ensure docker for desktop doesn't botch our service account rules
	kubectl delete clusterrolebinding docker-for-desktop-binding 2>/dev/null || true

	# apply the manifest
	sed -e "s/PLACEHOLDER_NAMESPACE/${NAMESPACE}/g" \
		-e "s/PLACEHOLDER_IMAGE_NAME/${IMAGE_NAME_DEV}/g" \
		-e "s/PLACEHOLDER_IMAGE_PULL_POLICY/Never/g" \
		"${MANIFEST_FILE}" | kubectl -n "${NAMESPACE}" apply -f -

	# wait for rollout of resource
	kubectl -n "${NAMESPACE}" rollout status "${KUBECTL_ROLLOUT_RESOURCE}" --watch --timeout=${KUBECTL_ROLLOUT_TIMEOUT}

	# port-forward and open shell to pod
	bash toolbox/access.sh "${NAMESPACE}" "${ACCESS_POD_NAME}" "${ACCESS_SHELL}" "${ACCESS_SVC_NAME}" "${ACCESS_SVC_PORT}"

	# delete the resources
	sed -e "s/PLACEHOLDER_NAMESPACE/${NAMESPACE}/g" \
		-e "s/PLACEHOLDER_IMAGE_NAME/${IMAGE_NAME}/g" \
		-e "s/PLACEHOLDER_IMAGE_PULL_POLICY/${IMAGE_PULL_POLICY}/g" \
		"${MANIFEST_FILE}"| kubectl -n "${NAMESPACE}" delete -f -

build:
	# build the container image
	docker build -t "${IMAGE_NAME}" .

	# edit out placeholders
	sed -e "s/PLACEHOLDER_NAMESPACE/${NAMESPACE}/g" \
		-e "s/PLACEHOLDER_IMAGE_NAME/${IMAGE_NAME}/g" \
		-e "s/PLACEHOLDER_IMAGE_PULL_POLICY/${IMAGE_PULL_POLICY}/g" \
		"${MANIFEST_FILE}" > manifests/deploy.yaml

	@echo
	@echo production manifest is located at manifests/deploy.yaml

shell:
	bash toolbox/access.sh "${NAMESPACE}" "${ACCESS_POD_NAME}" "${ACCESS_SHELL}"

access:
	bash toolbox/access.sh "${NAMESPACE}" "${ACCESS_POD_NAME}" "${ACCESS_SHELL}" "${ACCESS_SVC_NAME}" "${ACCESS_SVC_PORT}"

clean:
	rm -rf manifests/deploy.yaml

	# delete the resources
	sed -e "s/PLACEHOLDER_NAMESPACE/${NAMESPACE}/g" \
		-e "s/PLACEHOLDER_IMAGE_NAME/${IMAGE_NAME}/g" \
		-e "s/PLACEHOLDER_IMAGE_PULL_POLICY/${IMAGE_PULL_POLICY}/g" \
		"${MANIFEST_FILE}"| kubectl -n "${NAMESPACE}" delete -f - || true

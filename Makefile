NAME=registry
PORT=5000
CLUSTER_IP=10.254.0.51
LOCAL_REGISTRY=${CLUSTER_IP}:${PORT}
MANIFEST=./manifest

all: deploy

cp:
	@find ${MANIFEST}s -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ${MANIFEST}s -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ${MANIFEST}s -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ${MANIFEST}s -type f -name "*.yaml" | xargs sed -i s?"{{.port}}"?"${PORT}"?g
	@find ${MANIFEST}s -type f -name "*.yaml" | xargs sed -i s?"{{.image}}"?"${IMAGE}"?g
	@find ${MANIFEST}s -type f -name "*.yaml" | xargs sed -i s?"{{.image.pull.policy}}"?"${IMAGE_PULL_POLICY}"?g

deploy: export OP=create
deploy: cp sed
	@kubectl ${OP} -f ${MANIFEST}/service.yaml
	@kubectl ${OP} -f ${MANIFEST}/endpoint.yaml

del: export OP=delete
del:
	@kubectl ${OP} -f ${MANIFEST}/service.yaml
	@kubectl ${OP} -f ${MANIFEST}/endpoint.yaml
	@rm -f ${MANIFEST}/service.yaml
	@rm -f ${MANIFEST}/endpoint.yaml

clean: del

.PHONY : test
test:
	@curl http://${LOCAL_REGISTRY}/v2/_catalog

test1:
	@docker pull busybox
	@docker tag busybox ${LOCAL_REGISTRY}/busybox
	@docker push ${LOCAL_REGISTRY}/busybox

clean-test:
	@kubectl ${OP} -f ./test/test-claim.yaml -f ./test/test-pod.yaml

#!/bin/bash

set -x

PARENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/../.. && pwd )"
KUBEVIRTCI_DIR="$( cd ${PARENT_DIR}/../kubevirtci && pwd)"

okd_base_hash="sha256:73ede51ce464546a82b81956b7f58cf98662a4c5fded9c659b57746bc131e047"
gocli_image_hash="sha256:220f55f6b1bcb3975d535948d335bd0e6b6297149a3eba1a4c14cad9ac80f80d"

gocli="docker run \
--privileged \
--net=host \
--rm -t \
-v /var/run/docker.sock:/var/run/docker.sock \
-v ${PARENT_DIR}:${PARENT_DIR} \
docker.io/kubevirtci/gocli@${gocli_image_hash}"

provisioner_container_id=$(docker ps --filter name=ocp-4.4-provision-cluster --format {{.ID}})
docker kill $provisioner_container_id
docker container rm $provisioner_container_id

# For ocp-4.4 we want OVNKubernetes
${gocli} provision okd \
--prefix ocp-4.4-provision \
--dir-scripts ${PARENT_DIR}/okd/scripts \
--dir-manifests ${PARENT_DIR}/manifests \
--dir-hacks ${PARENT_DIR}/okd/hacks \
--skip-cnao \
--master-memory 10240 \
--workers-memory 8192 \
--workers-cpu 4 \
--networking-type OVNKubernetes \
--installer-pull-secret-file ${INSTALLER_PULL_SECRET} \
--installer-repo-tag release-4.4 \
--installer-release-image registry.svc.ci.openshift.org/ocp/release:4.4 \
"kubevirtci/okd-base@${okd_base_hash}"
rc=$?



exit $rc

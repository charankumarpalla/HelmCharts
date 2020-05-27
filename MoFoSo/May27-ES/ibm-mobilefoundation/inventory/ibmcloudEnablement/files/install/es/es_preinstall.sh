#!/bin/bash
# *****************************************************************
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2019. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# *****************************************************************

echo "Starting the es_preinstall script ..."

# Create/Switch Project for ES
${CASE_FILES_DIR}/install/utils/create_project.sh ${_GEN_ES_NAMESPACE}

_GEN_ES_IMG_PULLSECRET=es-image-docker-pull

echo "Creating image pull secret for Elasticsearch..."
#  create pull secret
oc create secret docker-registry ${_GEN_ES_IMG_PULLSECRET} -n ${_GEN_ES_NAMESPACE} --docker-server=${_SYSGEN_DOCKER_REGISTRY} --docker-username=${_SYSGEN_DOCKER_REGISTRY_USER} --docker-password=${_SYSGEN_DOCKER_REGISTRY_PASSWORD}
oc secrets -n ${_GEN_ES_NAMESPACE} link default ${_GEN_ES_IMG_PULLSECRET} --for=pull

sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd.yaml
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/es/deploy/role.yaml
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/es/deploy/role_binding.yaml
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/es/deploy/scc.yaml
sed -i "s|_ES_NAMESPACE_|${_GEN_ES_NAMESPACE}|g" ${CASE_FILES_DIR}/components/es/deploy/role_binding.yaml

# create CRD
oc create --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd.yaml

# create role
oc create --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/role.yaml

# create role-binding
oc create --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/role_binding.yaml

# create SCC
oc create --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/scc.yaml

# Create/Switch Project back to MF namespace
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE}

echo "ES Preinstall completed ..."
echo "*********************************************************************************************************************"
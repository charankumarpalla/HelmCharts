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

sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/es/deploy/operator.yaml
sed -i "s|_IMG_PULLSECRET_|es-image-docker-pull|g" ${CASE_FILES_DIR}/components/es/deploy/operator.yaml
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/es/deploy/service_account.yaml
sed -i "s|_IMG_PULLSECRET_|es-image-docker-pull|g" ${CASE_FILES_DIR}/components/es/deploy/service_account.yaml
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd.yaml

# delete service-account
oc delete --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/service_account.yaml

# delete SCC
oc delete --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/scc.yaml

# delete role-binding
oc delete --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/role_binding.yaml

# delete role
oc delete --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/role.yaml

# delete operator
oc delete --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/operator.yaml

# delete CRD
oc delete --namespace ${_GEN_ES_NAMESPACE} -f ${CASE_FILES_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd.yaml

# patch es to delete
oc patch esoperator.es.ibm.com ${_GEN_ES_NAMESPACE} -p '{"metadata":{"finalizers":[]}}' --type=merge"

echo "Uninstall of ES completed."
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

sed -i "s|_IMG_REPO_|${_SYSGEN_DOCKER_REGISTRY}|g" ${CASE_FILES_DIR}/components/db2/deploy/operator.yaml
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/db2/deploy/operator.yaml
sed -i "s|_IMG_PULLSECRET_|db2-image-docker-pull|g" ${CASE_FILES_DIR}/components/db2/deploy/operator.yaml
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/es/deploy/crds/charts_v1_esoperator_crd.yaml

# delete service-account
oc delete --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/db2u-saa.yaml

# delete SCC
oc delete --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/db2u-scc.yaml

# delete role-binding
oc delete --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/db2u-rolebinding.yaml

# delete role
oc delete --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/db2u-role.yaml

# delete operator
oc delete --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/operator.yaml

# delete CRD
oc delete --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/crds/charts_v1_db2operator_crd.yaml

# patching db2 deployment
oc patch db2/db2-primary -p '{"metadata":{"finalizers":[]}}' --type=merge 

echo "Uninstall of DB2 completed."


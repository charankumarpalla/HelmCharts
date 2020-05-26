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

OPERATOR_NAME=$1
DEPLOY_NAMESPACE=$2
IMG_PULLSECRET=$3

echo "Going to deploy the ${OPERATOR_NAME} operator ..."

# Create/Switch Project for ES
${CASE_FILES_DIR}/install/utils/create_project.sh ${DEPLOY_NAMESPACE}

CR_YAML="${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/crds/charts_v1_${OPERATOR_NAME}operator_cr.yaml"
OPERATOR_YAML="${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/operator.yaml"

if [ "${OPERATOR_NAME}" == "db2" ]
then
    SA_YAML="${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/db2u-sa.yaml"
else
    SA_YAML="${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/service_account.yaml"
fi

# Create Operator & service account
sed -i "s|_IMG_REPO_|${_SYSGEN_DOCKER_REGISTRY}|g" ${OPERATOR_YAML}
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${OPERATOR_YAML}
sed -i "s|_IMG_PULLPOLICY_|${image_pullPolicy}|g" ${OPERATOR_YAML}
sed -i "s|_IMG_PULLSECRET_|${IMG_PULLSECRET}|g" ${OPERATOR_YAML}
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${SA_YAML}
sed -i "s|_IMG_PULLSECRET_|${IMG_PULLSECRET}|g" ${SA_YAML}

# Create/Switch Project
${CASE_FILES_DIR}/install/utils/create_project.sh ${DEPLOY_NAMESPACE}

oc apply --namespace ${DEPLOY_NAMESPACE} -f ${SA_YAML}
oc apply --namespace ${DEPLOY_NAMESPACE} -f ${OPERATOR_YAML}

# give some time...
sleep 5

# Create/Switch Project for MF
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE}


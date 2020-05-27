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

CR_YAML="${CASE_FILES_DIR}/${OPERATOR_NAME}/deploy/crds/charts_v1_${OPERATOR_NAME}operator_cr.yaml"
OPERATOR_YAML="${CASE_FILES_DIR}/${OPERATOR_NAME}/deploy/operator.yaml"

if [ "${OPERATOR_NAME}" == "db2" ]
then
    SA_YAML="${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/db2u-sa.yaml"
else
    SA_YAML="${CASE_FILES_DIR}/components/${OPERATOR_NAME}/deploy/service_account.yaml"
fi


oc delete --namespace ${DEPLOY_NAMESPACE} -f ${CR_YAML}
oc delete --namespace ${DEPLOY_NAMESPACE} -f ${SA_YAML}
oc delete --namespace ${DEPLOY_NAMESPACE} -f ${OPERATOR_YAML}

oc delete --ignore-not-found --namespace ${DEPLOY_NAMESPACE} secret mobilefoundation-db-secret
oc delete --ignore-not-found --namespace ${DEPLOY_NAMESPACE} secret ${OPERATOR_NAME}-image-docker-pull

# give some time...
sleep 5

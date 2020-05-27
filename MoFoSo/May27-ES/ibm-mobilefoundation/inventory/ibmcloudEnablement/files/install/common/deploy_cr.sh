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

COMPONENT_NAME=$1
OPERATOR_NS=$2

echo "Deploying the ${COMPONENT_NAME} custom resource ..."

CR_YAML="${CASE_FILES_DIR}/components/${COMPONENT_NAME}/deploy/crds/charts_v1_${COMPONENT_NAME}operator_cr.yaml"

# Create/Switch Project for MF
${CASE_FILES_DIR}/install/utils/create_project.sh ${OPERATOR_NS}

#  Create the CR (deploy MF)
oc apply --namespace ${OPERATOR_NS} -f ${CR_YAML}
RC=$?
if [ $RC -ne 0 ]; then
    printf "Failed to apply custom CR for the component - ${COMPONENT_NAME}. Exiting..."
    exit $RC
fi
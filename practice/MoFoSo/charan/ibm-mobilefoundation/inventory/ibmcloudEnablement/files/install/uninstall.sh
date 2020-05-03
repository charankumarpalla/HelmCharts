#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2019. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

CASE_FILES_DIR=./ibm-mobilefoundation/inventory/ibmcloudEnablement/files

CR_YAML="${CASE_FILES_DIR}/deploy/crds/charts_v1_mfoperator_cr.yaml"
OPERATOR_YAML="${CASE_FILES_DIR}/deploy/operator.yaml"
SA_YAML="${CASE_FILES_DIR}/deploy/service_account.yaml"

echo -e ${CR_YAML}
echo -e ${OPERATOR_YAML}
echo -e ${SA_YAML}

kubectl delete -f ${CR_YAML} ${OPERATOR_YAML} ${SA_YAML}

echo "uninstall.sh"

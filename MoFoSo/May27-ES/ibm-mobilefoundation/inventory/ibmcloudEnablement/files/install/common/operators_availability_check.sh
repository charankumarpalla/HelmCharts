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

DEPLOYED_OPERATOR=$1
OPERATOR_NS=$2
OPERATOR_DESC=$3

${CASE_FILES_DIR}/install/utils/check_pods_by_label.sh ${OPERATOR_NS} "name=${DEPLOYED_OPERATOR}-operator" ${DEPLOYED_OPERATOR}
RC=$?
if [ $RC -ne 0 ]; then
    printf "\n${OPERATOR_DESC} not running...\n"
    exit $RC
fi
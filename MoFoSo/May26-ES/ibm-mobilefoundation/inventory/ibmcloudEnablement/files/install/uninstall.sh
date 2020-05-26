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

printf "\nUninstall procedure starting ...\n\n"

export _GEN_IMG_TAG=8.1.0
export CASE_FILES_DIR=./ibm-mobilefoundation/inventory/ibmcloudEnablement/files

export _SYSGEN_MF_NAMESPACE=${JOB_NAMESPACE}
export _GEN_DB2_NAMESPACE=${db_namespace:-mfdb}
export _GEN_ES_NAMESPACE=${elasticsearch_namespace:-mfes}

# Create/Switch Project for ES
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE}

oc projects | grep ${_GEN_DB2_NAMESPACE} >/dev/null 2>&1
if [ $? -eq 0 ]
then
    ${CASE_FILES_DIR}/install/cleanup/pre_uninstall.sh db2 ${_GEN_DB2_NAMESPACE}
    ${CASE_FILES_DIR}/install/cleanup/db2_cleanup.sh

    # delete the DB2 project
    ${CASE_FILES_DIR}/install/utils/delete_project.sh ${_GEN_DB2_NAMESPACE}
fi

oc projects | grep ${_GEN_ES_NAMESPACE} >/dev/null 2>&1
if [ $? -eq 0 ]
then
    ${CASE_FILES_DIR}/install/cleanup/pre_uninstall.sh es ${_GEN_ES_NAMESPACE}
    ${CASE_FILES_DIR}/install/cleanup/es_cleanup.sh

    # delete the ES project
    ${CASE_FILES_DIR}/install/utils/delete_project.sh ${_GEN_ES_NAMESPACE}
fi

${CASE_FILES_DIR}/install/cleanup/pre_uninstall.sh mf ${_SYSGEN_MF_NAMESPACE}
${CASE_FILES_DIR}/install/cleanup/mf_cleanup.sh

# delete the MF project
${CASE_FILES_DIR}/install/utils/delete_project.sh ${_SYSGEN_MF_NAMESPACE}


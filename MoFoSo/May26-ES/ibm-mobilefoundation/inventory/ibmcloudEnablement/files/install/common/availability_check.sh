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
# print the readiness check return value
printReturnMsg() {
	RC=$1
	COMPONENT=$2
	if [ $RC -ne 0 ]; then
		printf "\n$2 readiness check failed.\n"
		exit $RC
	fi
}

#
#  if analytics receiver is enabled without enabling analytics
#  disable the analytics receiver to prevent from unnecessary deployment
#  of the receiver component
#
if [ "${mfpanalytics_recvr_enabled}" == "true" ] && [ "${mfpanalytics_enabled}" == "false" ]
then
	_GEN_RECVR_ENABLE=false
else
	_GEN_RECVR_ENABLE=${mfpanalytics_recvr_enabled}
fi

checkMFReadiness()
{
	if [ "${mfpserver_enabled}" == "true" ]; then
		printf "\nCheck Liveliness and Readiness of Mobile Foundation Server component.\n"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-8.1.0,component=server ui
		printReturnMsg $? "Mobile Foundation Server"
	fi

	if [ "${mfppush_enabled}" == "true" ]; then
		printf "\nCheck Liveliness and Readiness of Mobile Foundation Push component.\n"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-8.1.0,component=push ui
		printReturnMsg $? "Mobile Foundation Push"
	fi

	if [ "${mfpliveupdate_enabled}" == "true" ]; then
		printf "\nCheck Liveliness and Readiness of Mobile Foundation LiveUpdate component.\n"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-8.1.0,component=liveupdate ui
		printReturnMsg $? "Mobile Foundation Liveupdate"
	fi

	if [ "${_GEN_RECVR_ENABLE}" == "true" ]; then
		printf "\nCheck Liveliness and Readiness of Mobile Foundation Analytics Receiver component.\n"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-8.1.0,component=analytics-recvr ui
		printReturnMsg $? "Mobile Foundation Analytics Receiver"
	fi

	if [ "${mfpanalytics_enabled}" == "true" ]; then
		printf "\nCheck Liveliness and Readiness of Mobile Foundation Analytics component.\n"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-8.1.0,component=analytics ui
		printReturnMsg $? "Mobile Foundation Analytics Service"
	fi

	if [ "${mfpappcenter_enabled}" == "true" ]; then
		printf "\nCheck Liveliness and Readiness of Mobile Foundation Application Center component.\n"
		${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-8.1.0,component=appcenter ui
		printReturnMsg $? appcenter
	fi
}

checkDB2Readiness()
{
	printf "\nCheck Liveliness and Readiness of DB2-etcd components.\n"
    ${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_GEN_DB2_NAMESPACE} chart=ibm-db2-prod,component=etcd db2 60
    printReturnMsg $? db2-etcd

    printf "\nCheck Liveliness and Readiness of DB2-tools pod.\n"
    ${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_GEN_DB2_NAMESPACE} chart=ibm-db2-prod,component=db2oltp,type=tools db2 60
    printReturnMsg $? db2u-tools

    printf "\nCheck Liveliness and Readiness of DB2-primary pod.\n"
    ${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_GEN_DB2_NAMESPACE} chart=ibm-db2-prod,statefulset.kubernetes.io/pod-name=db2-primary-ibm-db2u-db2u-0,type=engine db2 120
    printReturnMsg $? db2-primary-component	
}

checkESReadiness()
{
	printf "\nCheck Liveliness and Readiness of Elasticsearch client component.\n"
    ${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_GEN_ES_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-${_GEN_ES_IMG_TAG},esnode=client backend
    printReturnMsg $? Elasticsearch-client

    printf "\nCheck Liveliness and Readiness of Elasticsearch master component.\n"
    ${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_GEN_ES_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-${_GEN_ES_IMG_TAG},esnode=master backend
    printReturnMsg $? Elasticsearch-master

    printf "\nCheck Liveliness and Readiness of Elasticsearch data component.\n"
    ${CASE_FILES_DIR}/install/utils/check_pods_ready.sh ${_GEN_ES_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-${_GEN_ES_IMG_TAG},esnode=data backend
    printReturnMsg $? Elasticsearch-data
}

#
# main
#

COMPONENT_NAME=$1

if [ "$COMPONENT_NAME" == "db2" ]
then
	checkESReadiness $COMPONENT_NAME
fi

if [ "$COMPONENT_NAME" == "es" ]
then
	checkDB2Readiness $COMPONENT_NAME
fi

if [ "$COMPONENT_NAME" == "mf" ]
then
	checkMFReadiness $COMPONENT_NAME
fi
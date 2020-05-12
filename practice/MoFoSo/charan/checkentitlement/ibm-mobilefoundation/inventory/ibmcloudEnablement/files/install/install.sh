#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2019. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

echo "Install procedure starting ..."

CASE_FILES_DIR=./ibm-mobilefoundation/inventory/ibmcloudEnablement/files

CR_YAML="${CASE_FILES_DIR}/deploy/crds/charts_v1_mfoperator_cr.yaml"
OPERATOR_YAML="${CASE_FILES_DIR}/deploy/operator.yaml"
SA_YAML="${CASE_FILES_DIR}/deploy/service_account.yaml"

#
#  Make a copy of CR Yaml
#
cp ${CR_YAML} ${CR_YAML}

#
# Following are to be used from the builtin ENV variables
#
_SYSGEN_MF_NAMESPACE=${JOB_NAMESPACE}
export _SYSGEN_DOCKER_REGISTRY=${DOCKER_REGISTRY}
export _SYSGEN_DOCKER_REGISTRY_USER=${DOCKER_REGISTRY_USER}
export _SYSGEN_DOCKER_REGISTRY_PASS=${DOCKER_REGISTRY_PASS}

echo "================>>>>. TEST ENTITLEMENT CHECK"
echo -e "_SYSGEN_DOCKER_REGISTRY = $_SYSGEN_DOCKER_REGISTRY \n _SYSGEN_DOCKER_REGISTRY_USER =  $_SYSGEN_DOCKER_REGISTRY_USER  \n _SYSGEN_DOCKER_REGISTRY_PASS=$_SYSGEN_DOCKER_REGISTRY_PASS"

echo ***********************************************
echo _SYSGEN_MF_NAMESPACE=${_SYSGEN_MF_NAMESPACE}
echo ***********************************************

# export _SYSGEN_DOCKER_REGISTRY="cp.stg.icr.io"
# export _SYSGEN_DOCKER_REGISTRY_USER="iamapikey"
# export _SYSGEN_DOCKER_REGISTRY_PASSWORD="lmTwt2gWsxJk25XAFATqGqkdWxWWOdsSfJhYL7Gomslo"

addConfigPropertiesToCustomResource() {
	#
	#  ingress/route specifics
	#

	sed -i "s|_IMG_PULLPOLICY_|${image_pullPolicy}|g" ${CR_YAML}
	sed -i "s|_IMG_PULLSECRET_|${_GEN_IMG_PULLSECRET}|g" ${CR_YAML}
	sed -i "s|_INGRESS_HOSTNAME_|${INGRESS_HOSTNAME}|g" ${CR_YAML}
	sed -i "s|_INGRESS_SECRET_|${ingress_secret}|g" ${CR_YAML}
	sed -i "s|_SSL_PASSTHROUGH_|${ingress_sslPassThrough}|g" ${CR_YAML}
	sed -i "s|_ENABLE_HTTPS_|${ingress_https}|g" ${CR_YAML}

	#
	# DB tasks
	#

	sed -i "s|_DB_TYPE_|${db_type}|g" ${CR_YAML}
	sed -i "s|_MFPF_DB_HOST_|${db_host}|g" ${CR_YAML}
	sed -i "s|_MFPF_DB_PORT_|${db_port}|g" ${CR_YAML}
	sed -i "s|_MFPF_DB_NAME_|${db_name}|g" ${CR_YAML}
	sed -i "s|_MFPF_DB_SECRET_|${_GEN_DB_SECRET_NAME}|g" ${CR_YAML}
	sed -i "s|_MFPF_DB_SCHEMA_|${db_schema}|g" ${CR_YAML}
	sed -i "s|_MFPF_DB_SSL_ENABLE_|${db_ssl}|g" ${CR_YAML}
	sed -i "s|_MFPF_DB_DRIVER_PVC_|${db_driverPvc}|g" ${CR_YAML}
	sed -i "s|_MFPF_DBADMIN_CRED_SECRET_|${db_adminCredentialsSecret}|g" ${CR_YAML}

	#
	# dbinit
	#
	sed -i "s|_DBINIT_ENABLE_|${dbinit_enabled}|g" ${CR_YAML}
	sed -i "s|_DBINIT_IMG_REPO_|${_GEN_DBINIT_IMG_REPO}|g" ${CR_YAML}
	sed -i "s|_DBINIT_IMG_TAG_|${_GEN_DBINIT_IMG_TAG}|g" ${CR_YAML}
	sed -i "s|_DBINIT_RR_CPU_|${dbinit_resources_requests_cpu}|g" ${CR_YAML}
	sed -i "s|_DBINIT_RR_MEM_|${dbinit_resources_requests_memory}|g" ${CR_YAML}
	sed -i "s|_DBINIT_RL_CPU_|${dbinit_resources_limits_cpu}|g" ${CR_YAML}
	sed -i "s|_DBINIT_RL_MEM_|${dbinit_resources_limits_memory}|g" ${CR_YAML}

	#
	# mfpserver
	#
	sed -i "s|_SERVER_ENABLE_|${mfpserver_enabled}|g" ${CR_YAML}
	sed -i "s|_SERVER_IMG_REPO_|${_GEN_SERVER_IMG_REPO}|g" ${CR_YAML}
	sed -i "s|_SERVER_IMG_TAG_|${_GEN_SERVER_IMG_TAG}|g" ${CR_YAML}
	sed -i "s|_SERVER_CONSOLE_SECRET_|${_GEN_SERVER_CONSOLE_SECRET}|g" ${CR_YAML}
	sed -i "s|_SERVER_ADMINCLIENT_SECRET_|${mfpserver_adminClientSecret}|g" ${CR_YAML}
	sed -i "s|_SERVER_PUSHCLIENT_SECRET_|${mfpserver_pushClientSecret}|g" ${CR_YAML}
	sed -i "s|_SERVER_LUCLIENT_SECRET_|${mfpserver_liveupdateClientSecret}|g" ${CR_YAML}
	sed -i "s|_SERVER_ICS_ADMINCLIENT_SECRET_ID_|${mfpserver_internalClientSecretDetails_adminClientSecretId}|g" ${CR_YAML}
	sed -i "s|_SERVER_ICS_ADMINCLIENT_SECRET_PASSWORD_|${mfpserver_internalClientSecretDetails_adminClientSecretPassword}|g" ${CR_YAML}
	sed -i "s|_SERVER_ICS_PUSHCLIENT_SECRETID_|${mfpserver_internalClientSecretDetails_pushClientSecretId}|g" ${CR_YAML}
	sed -i "s|_SERVER_ICS_PUSHCLIENT_SECRET_PASSWORD_|${mfpserver_internalClientSecretDetails_pushClientSecretPassword}|g" ${CR_YAML}
	sed -i "s|_SERVER_REPLICAS_|${mfpserver_replicas}|g" ${CR_YAML}
	sed -i "s|_SERVER_AUTOSCALING_ENABLE_|${mfpserver_autoscaling_enabled}|g" ${CR_YAML}
	sed -i "s|_SERVER_AUTOSCALING_MIN_|${mfpserver_autoscaling_min}|g" ${CR_YAML}
	sed -i "s|_SERVER_AUTOSCALING_MAX_|${mfpserver_autoscaling_max}|g" ${CR_YAML}
	sed -i "s|_SERVER_AUTOSCALING_TARGET_CPU_|${mfpserver_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i "s|_SERVER_PDB_ENABLE_|${mfpserver_pdb_enabled}|g" ${CR_YAML}
	sed -i "s|_SERVER_PDB_MIN_|${mfpserver_pdb_min}|g" ${CR_YAML}
	sed -i "s|_SERVER_CUST_CONFIG_|${mfpserver_customConfiguration}|g" ${CR_YAML}
	sed -i "s|_SERVER_KEYSTORE_SECRET_|${mfpserver_keystoreSecret}|g" ${CR_YAML}
	sed -i "s|_SERVER_RR_CPU_|${mfpserver_resources_requests_cpu}|g" ${CR_YAML}
	sed -i "s|_SERVER_RR_MEM_|${mfpserver_resources_requests_memory}|g" ${CR_YAML}
	sed -i "s|_SERVER_RL_CPU_|${mfpserver_resources_limits_cpu}|g" ${CR_YAML}
	sed -i "s|_SERVER_RL_MEM_|${mfpserver_resources_limits_memory}|g" ${CR_YAML}

	#
	# mfppush
	#
	sed -i "s|_PUSH_ENABLE_|${mfppush_enabled}|g" ${CR_YAML}
	sed -i "s|_PUSH_IMG_REPO_|${_GEN_PUSH_IMG_REPO}|g" ${CR_YAML}
	sed -i "s|_PUSH_IMG_TAG_|${_GEN_PUSH_IMG_TAG}|g" ${CR_YAML}
	sed -i "s|_PUSH_REPLICAS_|${mfppush_replicas}|g" ${CR_YAML}
	sed -i "s|_PUSH_AUTOSCALING_ENABLE_|${mfppush_autoscaling_enabled}|g" ${CR_YAML}
	sed -i "s|_PUSH_AUTOSCALING_MIN_|${mfppush_autoscaling_min}|g" ${CR_YAML}
	sed -i "s|_PUSH_AUTOSCALING_MAX_|${mfppush_autoscaling_max}|g" ${CR_YAML}
	sed -i "s|_PUSH_AUTOSCALING_TARGET_CPU_|${mfppush_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i "s|_PUSH_PDB_ENABLE_|${mfppush_pdb_enabled}|g" ${CR_YAML}
	sed -i "s|_PUSH_PDB_MIN_|${mfppush_pdb_min}|g" ${CR_YAML}
	sed -i "s|_PUSH_CUST_CONFIG_|${mfppush_customConfiguration}|g" ${CR_YAML}
	sed -i "s|_PUSH_KEYSTORE_SECRET_|${mfppush_keystoreSecret}|g" ${CR_YAML}
	sed -i "s|_PUSH_RR_CPU_|${mfppush_resources_requests_cpu}|g" ${CR_YAML}
	sed -i "s|_PUSH_RR_MEM_|${mfppush_resources_requests_memory}|g" ${CR_YAML}
	sed -i "s|_PUSH_RL_CPU_|${mfppush_resources_limits_cpu}|g" ${CR_YAML}
	sed -i "s|_PUSH_RL_MEM_|${mfppush_resources_limits_memory}|g" ${CR_YAML}

	#
	# mfpliveupdate
	#
	sed -i "s|_LU_ENABLE_|${mfpliveupdate_enabled}|g" ${CR_YAML}
	sed -i "s|_LU_IMG_REPO_|${_GEN_LU_IMG_REPO}|g" ${CR_YAML}
	sed -i "s|_LU_IMG_TAG_|${_GEN_LU_IMG_TAG}|g" ${CR_YAML}
	sed -i "s|_LU_REPLICAS_|${mfpliveupdate_replicas}|g" ${CR_YAML}
	sed -i "s|_LU_AUTOSCALING_ENABLE_|${mfpliveupdate_autoscaling_enabled}|g" ${CR_YAML}
	sed -i "s|_LU_AUTOSCALING_MIN_|${mfpliveupdate_autoscaling_min}|g" ${CR_YAML}
	sed -i "s|_LU_AUTOSCALING_MAX_|${mfpliveupdate_autoscaling_max}|g" ${CR_YAML}
	sed -i "s|_LU_AUTOSCALING_TARGET_CPU_|${mfpliveupdate_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i "s|_LU_PDB_ENABLE_|${mfpliveupdate_pdb_enabled}|g" ${CR_YAML}
	sed -i "s|_LU_PDB_MIN_|${mfpliveupdate_pdb_min}|g" ${CR_YAML}
	sed -i "s|_LU_CUST_CONFIG_|${mfpliveupdate_customConfiguration}|g" ${CR_YAML}
	sed -i "s|_LU_KEYSTORE_SECRET_|${mfpliveupdate_keystoreSecret}|g" ${CR_YAML}
	sed -i "s|_LU_RR_CPU_|${mfpliveupdate_resources_requests_cpu}|g" ${CR_YAML}
	sed -i "s|_LU_RR_MEM_|${mfpliveupdate_resources_requests_memory}|g" ${CR_YAML}
	sed -i "s|_LU_RL_CPU_|${mfpliveupdate_resources_limits_cpu}|g" ${CR_YAML}
	sed -i "s|_LU_RL_MEM_|${mfpliveupdate_resources_limits_memory}|g" ${CR_YAML}

	#
	# mfpanalytics
	#
	sed -i "s|_ANALYTICS_ENABLE_|${mfpanalytics_enabled}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_IMG_REPO_|${_GEN_ANALYTICS_IMG_REPO}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_IMG_TAG_|${_GEN_ANALYTICS_IMG_TAG}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_CONSOLE_SECRET_|${_GEN_ANALYTICS_CONSOLE_SECRET}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_REPLICAS_|${mfpanalytics_replicas}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_AUTOSCALING_ENABLE_|${mfpanalytics_autoscaling_enabled}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_AUTOSCALING_MIN_|${mfpanalytics_autoscaling_min}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_AUTOSCALING_MAX_|${mfpanalytics_autoscaling_max}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_AUTOSCALING_TARGET_CPU_|${mfpanalytics_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_SHARDS_|${mfpanalytics_shards}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_RPLICAS_PER_SHARD_|${mfpanalytics_replicasPerShard}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_PERSISTENCE_ENABLE_|${mfpanalytics_persistence_enabled}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_PERSISTENCE_DYNAPROV_ENABLE_|${mfpanalytics_useDynamicProvisioning_enabled}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_PERSISTENCE_VOLNAME_|${mfpanalytics_persistence_volumeName}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_PERSISTENCE_CLAIMNAME_|${mfpanalytics_persistence_claimName}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_PERSISTENCE_STORAGENAME_|${mfpanalytics_persistence_storageClassName}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_PERSISTENCE_DISK_SIZE_|${mfpanalytics_persistence_size}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_PDB_ENABLE_|${mfpanalytics_pdb_enabled}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_PDB_MIN_|${mfpanalytics_pdb_min}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_CUST_CONFIG_|${mfpanalytics_customConfiguration}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_KEYSTORE_SECRET_|${mfpanalytics_keystoreSecret}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_RR_CPU_|${mfpanalytics_resources_requests_cpu}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_RR_MEM_|${mfpanalytics_resources_requests_memory}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_RL_CPU_|${mfpanalytics_resources_requests_limits_cpu}|g" ${CR_YAML}
	sed -i "s|_ANALYTICS_RL_MEM_|${mfpanalytics_resources_requests_limits_memory}|g" ${CR_YAML}

	#
	# mfpanalytics_recvr
	#
	sed -i "s|_RECVR_ENABLE_|${_GEN_RECVR_ENABLE}|g" ${CR_YAML}
	sed -i "s|_RECVR_IMG_REPO_|${_GEN_RECVR_IMG_REPO}|g" ${CR_YAML}
	sed -i "s|_RECVR_IMG_TAG_|${_GEN_RECVR_IMG_TAG}|g" ${CR_YAML}
	sed -i "s|_RECVR_REPLICAS_|${mfpanalytics_recvr_replicas}|g" ${CR_YAML}
	sed -i "s|_RECVR_AUTOSCALING_ENABLE_|${mfpanalytics_recvr_autoscaling_enabled}|g" ${CR_YAML}
	sed -i "s|_RECVR_AUTOSCALING_MIN_|${mfpanalytics_recvr_autoscaling_min}|g" ${CR_YAML}
	sed -i "s|_RECVR_AUTOSCALING_MAX_|${mfpanalytics_recvr_autoscaling_max}|g" ${CR_YAML}
	sed -i "s|_RECVR_AUTOSCALING_TARGET_CPU_|${mfpanalytics_recvr_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i "s|_RECVR_PDB_ENABLE_|${mfpanalytics_recvr_pdb_enabled}|g" ${CR_YAML}
	sed -i "s|_RECVR_PDB_MIN_|${mfpanalytics_recvr_pdb_min}|g" ${CR_YAML}
	sed -i "s|_RECVR_SECRET_|${mfpanalytics_recvr_analyticsRecvrSecret}|g" ${CR_YAML}
	sed -i "s|_RECVR_CUST_CONFIG_|${mfpanalytics_recvr_customConfiguration}|g" ${CR_YAML}
	sed -i "s|_RECVR_KEYSTORE_SECRET_|${mfpanalytics_recvr_keystoreSecret}|g" ${CR_YAML}
	sed -i "s|_RECVR_RR_CPU_|${mfpanalytics_recvr_resources_requests_cpu}|g" ${CR_YAML}
	sed -i "s|_RECVR_RR_MEM_|${mfpanalytics_recvr_resources_requests_memory}|g" ${CR_YAML}
	sed -i "s|_RECVR_RL_CPU_|${mfpanalytics_recvr_resources_limits_cpu}|g" ${CR_YAML}
	sed -i "s|_RECVR_RL_MEM_|${mfpanalytics_recvr_resources_limits_memory}|g" ${CR_YAML}

	#
	# mfpappcenter
	#
	sed -i "s|_AC_ENABLE_|${mfpappcenter_enable}|g" ${CR_YAML}
	sed -i "s|_AC_IMG_REPO_|${_GEN_AC_IMG_REPO}|g" ${CR_YAML}
	sed -i "s|_AC_IMG_TAG_|${_GEN_AC_IMG_TAG}|g" ${CR_YAML}
	sed -i "s|_AC_CONSOLE_SECRET_|${_GEN_AC_CONSOLE_SECRET}|g" ${CR_YAML}
	sed -i "s|_AC_REPLICAS_|${mfpappcenter_replicas}|g" ${CR_YAML}
	sed -i "s|_AC_AUTOSCALING_ENABLE_|${mfpappcenter_autoscaling_enabled}|g" ${CR_YAML}
	sed -i "s|_AC_AUTOSCALING_MIN_|${mfpappcenter_autoscaling_min}|g" ${CR_YAML}
	sed -i "s|_AC_AUTOSCALING_MAX_|${mfpappcenter_autoscaling_max}|g" ${CR_YAML}
	sed -i "s|_AC_AUTOSCALING_TARGET_CPU_|${mfpappcenter_autoscaling_targetcpu}|g" ${CR_YAML}
	sed -i "s|_AC_PDB_ENABLE_|${mfpappcenter_pdb_enabled}|g" ${CR_YAML}
	sed -i "s|_AC_PDB_MIN_|${mfpappcenter_pdb_min}|g" ${CR_YAML}
	sed -i "s|_AC_CUST_CONFIG_|${mfpappcenter_customConfiguration}|g" ${CR_YAML}
	sed -i "s|_AC_KEYSTORE_SECRET_|${mfpappcenter_keystoreSecret}|g" ${CR_YAML}
	sed -i "s|_AC_RR_CPU_|${mfpappcenter_resources_requests_cpu}|g" ${CR_YAML}
	sed -i "s|_AC_RR_MEM_|${mfpappcenter_resources_requests_memory}|g" ${CR_YAML}
	sed -i "s|_AC_RL_CPU_|${mfpappcenter_resources_limits_cpu}|g" ${CR_YAML}
	sed -i "s|_AC_RL_MEM_|${mfpappcenter_resources_limits_memory}|g" ${CR_YAML}
}

# list the components enabled
echo ""
echo "Following are the Mobile Foundation components enabled"
[ "${mfpserver_enabled}" == "true" ] && echo " > Mobile Foundation Server"
[ "${mfppush_enabled}" == "true" ] && echo " > Push"
[ "${mfpliveupdate_enabled}" == "true" ] && echo " > LiveUpdate"
[ "${mfpanalytics_recvr_enabled}" == "true" ] && echo " > Analytics Receiver"
[ "${mfpanalytics_enabled}" == "true" ] && echo " > Mobile Foundation Analytics"
[ "${mfpappcenter_enabled}" == "true" ] && echo " > Application Center"
echo ""

#
# Check for inter component relationship and validate
# - Only Push cannot be enabled alone without enabling Server
# - Analytics reciver cannot be enabled alone without Analytics

if [ "${mfppush_enabled}" == "true" ] && [ "${mfpserver_enabled}" == "false" ]; then
	# exit the deployment with failure
	echo " Server component must be enabled to use Push. Exiting ..."
	exit 1
fi

if [ "${mfpliveupdate_enabled}" == "true" ] && [ "${mfpserver_enabled}" == "false" ]; then
	# exit the deployment with failure
	echo " Server component must be enabled to use Live Update. Exiting ..."
	exit 1
fi

# if analytics receiver is enabled without enabling analytics
#  disable the analytics receiver to prevent from unnecessary deployment
#  of the receiver component
if [ "${mfpanalytics_recvr_enabled}" == "true" ] && [ "${mfpanalytics_enabled}" == "false" ]; then
	_GEN_RECVR_ENABLE=false
else
	_GEN_RECVR_ENABLE=${mfpanalytics_recvr_enabled}
fi

#
#  Set image pull secret name
#
_GEN_IMG_PULLSECRET=mf-image-docker-pull
#
# create pull secret
#
kubectl create secret docker-registry ${_GEN_IMG_PULLSECRET} -n ${_SYSGEN_MF_NAMESPACE} --docker-server=${_SYSGEN_DOCKER_REGISTRY} --docker-username=${_SYSGEN_DOCKER_REGISTRY_USER} --docker-password=${_SYSGEN_DOCKER_REGISTRY_PASSWORD}
kubectl secrets -n ${_SYSGEN_MF_NAMESPACE} link default ${_GEN_IMG_PULLSECRET} --for=pull

#
# Enable HTTPS at Ingress/Route Level
#

# Create service account
sed -i "s|_IMG_REPO_|${_SYSGEN_DOCKER_REGISTRY}/cp|g" ${OPERATOR_YAML}
sed -i "s|_IMG_PULLSECRET_|${_GEN_IMG_PULLSECRET}|g" ${OPERATOR_YAML}
sed -i "s|_IMG_PULLSECRET_|${_GEN_IMG_PULLSECRET}|g" ${SA_YAML}

# print the readiness check return value
printReturnMsg() {
	RC=$1
	COMPONENT=$2
	if [ $RC -ne 0 ]; then
		echo "Mobile Foundation $2 readiness check failed."
		# exit $RC
	fi
}

# Create Operator & service account
kubectl apply --namespace ${JOB_NAMESPACE} -f ${OPERATOR_YAML}
kubectl apply --namespace ${JOB_NAMESPACE} -f ${SA_YAML}

sleep 5
#
# Check Pod status
#
echo ""
./ibm-mobilefoundation/inventory/ibmcloudEnablement/files/install/check_pods_by_label.sh ${_SYSGEN_MF_NAMESPACE} name=mf-operator mf-operator
RC=$?
if [ $RC -ne 0 ]; then
	echo "Mobile Foundation Operator not running..."
	# exit $RC
fi
echo ""

############################
# setting image names
############################
_GEN_DBINIT_IMG_REPO=${dbinit_repository}
_GEN_DBINIT_IMG_TAG=${dbinit_tag}
_GEN_SERVER_IMG_REPO=${mfpserver_repository}
_GEN_SERVER_IMG_TAG=${mfpserver_tag}
_GEN_PUSH_IMG_REPO=${mfppush_repository}
_GEN_PUSH_IMG_TAG=${mfppush_tag}
_GEN_LU_IMG_REPO_=${mfpliveupdate_repository}
_GEN_LU_IMG_TAG_=${mfpliveupdate_tag}
_GEN_ANALYTICS_IMG_REPO=${mfpanalytics_repository}
_GEN_ANALYTICS_IMG_TAG=${mfpanalytics_tag}
_GEN_RECVR_IMG_REPO=${mfpanalytics_recvr_repository}
_GEN_RECVR_IMG_TAG=${mfpanalytics_recvr_tag}
_GEN_AC_IMG_REPO=${mfpappcenter_repository}
_GEN_AC_IMG_TAG=${mfpappcenter_tag}

#################################
echo "Generate DB secret"
#################################

if [ "${mfpserver_enabled}" == "true" ] || [ "${mfppush_enabled}" == "true" ] || [ "${mfpliveupdate_enabled}" == "true" ] || [ "${mfpappcenter_enabled}" == "true" ]; then

	_GEN_DB_SECRET_NAME="mobilefoundation-db-secret"
	_GEN_DB_USERID_BASE64=$(echo -n "${db_userid}" | base64)
	_GEN_DB_PASSWORD_BASE64=$(echo -n "${db_password}" | base64)

	DB_SECRET_STRING="apiVersion: v1\n"
	DB_SECRET_STRING="${DB_SECRET_STRING}data:\n"

	if [ "${mfpserver_enabled}" == "true" ]; then
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_ADMIN_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_ADMIN_DB_PASSWORD: ${_GEN_DB_PASSWORD_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_RUNTIME_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_RUNTIME_DB_PASSWORD: ${_GEN_DB_PASSWORD_BASE64}\n"
	fi

	if [ "${mfppush_enabled}" == "true" ]; then
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_PUSH_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_PUSH_DB_PASSWORD: ${_GEN_DB_PASSWORD_BASE64}\n"
	fi

	if [ "${mfpliveupdate_enabled}" == "true" ]; then
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_LIVEUPDATE_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_LIVEUPDATE_DB_PASSWORD: ${_GEN_DB_PASSWORD_BASE64}\n"
	fi

	if [ "${mfpappcenter_enabled}" == "true" ]; then
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_APPCNTR_DB_USERNAME: ${_GEN_DB_USERID_BASE64}\n"
		DB_SECRET_STRING="${DB_SECRET_STRING}  MFPF_APPCNTR_DB_USERNAME: ${_GEN_DB_PASSWORD_BASE64}\n"
	fi

	DB_SECRET_STRING="${DB_SECRET_STRING}kind: Secret\n"
	DB_SECRET_STRING="${DB_SECRET_STRING}metadata:\n"
	DB_SECRET_STRING="${DB_SECRET_STRING}  name: ${_GEN_DB_SECRET_NAME}\n"
	DB_SECRET_STRING="${DB_SECRET_STRING}type: Opaque"

	echo -e "${DB_SECRET_STRING}" >${_GEN_DB_SECRET_NAME}.yaml

	kubectl apply --namespace ${JOB_NAMESPACE} -f ${_GEN_DB_SECRET_NAME}.yaml

	RC=$?

	if [ $RC -ne 0 ]; then
		echo "Mobile Foundation database secret creation failure."
		# exit $RC
	fi

	rm -f ${_GEN_DB_SECRET_NAME}.yaml

fi

#################################
echo "Console Login Secrets"
#################################

# create server login secret

if [ "${mfpserver_enabled}" == "true" ]; then

	_GEN_SERVER_CONSOLE_SECRET=serverlogin
	_GEN_SERVER_CONSOLE_USERID_BASE64=$(echo -n ${mfpserver_consoleUserid} | base64)
	_GEN_SERVER_CONSOLE_PASSWORD_BASE64=$(echo -n ${mfpserver_consolePassword} | base64)

	cat <<EOF | kubectl apply --namespace ${JOB_NAMESPACE} -f -
apiVersion: v1
data:
  MFPF_ADMIN_USER: ${_GEN_SERVER_CONSOLE_USERID_BASE64}
  MFPF_ADMIN_PASSWORD: ${_GEN_SERVER_CONSOLE_PASSWORD_BASE64}
kind: Secret
metadata:
  name: ${_GEN_SERVER_CONSOLE_SECRET}
type: Opaque
EOF

fi

# create analytics login secret

if [ "${mfpanalytics_enabled}" == "true" ]; then

	_GEN_ANALYTICS_CONSOLE_SECRET=analyticslogin
	_GEN_ANALYTICS_CONSOLE_USERID_BASE64=$(echo -n ${mfpanalytics_consoleUserid} | base64)
	_GEN_ANALYTICS_CONSOLE_PASSWORD_BASE64=$(echo -n ${mfpanalytics_consolePassword} | base64)

	cat <<EOF | kubectl apply --namespace ${JOB_NAMESPACE} -f -
apiVersion: v1
data:
  MFPF_ANALYTICS_ADMIN_USER: ${_GEN_ANALYTICS_CONSOLE_USERID_BASE64}
  MFPF_ANALYTICS_ADMIN_PASSWORD: ${_GEN_ANALYTICS_CONSOLE_PASSWORD_BASE64}
kind: Secret
metadata:
  name: ${_GEN_ANALYTICS_CONSOLE_SECRET}
type: Opaque
EOF

fi

# create appcenter login secret

if [ "${mfpappcenter_enabled}" == "true" ]; then

	_GEN_AC_CONSOLE_SECRET=appcntrlogin
	_GEN_APPCENTER_CONSOLE_USERID_BASE64=$(echo -n ${mfpappcenter_consoleUserid} | base64)
	_GEN_APPCENTER_CONSOLE_PASSWORD_BASE64=$(echo -n ${mfpappcenter_consolePassword} | base64)

	cat <<EOF | kubectl apply --namespace ${JOB_NAMESPACE} -f -
apiVersion: v1
data:
  MFPF_APPCNTR_ADMIN_USER: ${_GEN_APPCENTER_CONSOLE_USERID_BASE64}
  MFPF_APPCNTR_ADMIN_PASSWORD: ${_GEN_APPCENTER_CONSOLE_PASSWORD_BASE64}
kind: Secret
metadata:
  name: ${_GEN_AC_CONSOLE_SECRET}
type: Opaque
EOF

fi

#
#  Assign permission for the Analytics Datastore
#
if [ "${mfpanalytics_enabled}" == "true" ]; then
	echo ""
	echo " Assign permission for the Analytics Datastore"
	./ibm-mobilefoundation/inventory/ibmcloudEnablement/files/install/analytics_vol_perms.sh ${_SYSGEN_MF_NAMESPACE} ${mfpanalytics_persistence_volumeName}
fi

#
# start to fill up the CR yaml
#
addConfigPropertiesToCustomResource

echo ""
# Create the CR (deploy MF)
kubectl apply --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CR_YAML}

#
# Check if the the MF pods is available
#

if [ "${mfpserver_enabled}" == "true" ]; then
	echo ""
	echo "Check Liveliness and Readiness of Mobile Foundation Server component"
	./ibm-mobilefoundation/inventory/ibmcloudEnablement/files/install/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-3.1.3,component=server ui
	printReturnMsg $? server
fi

if [ "${mfppush_enabled}" == "true" ]; then
	echo ""
	echo "Check Liveliness and Readiness of Mobile Foundation Push component"
	./ibm-mobilefoundation/inventory/ibmcloudEnablement/files/install/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-3.1.3,component=push ui
	printReturnMsg $? push
fi

if [ "${mfpliveupdate_enabled}" == "true" ]; then
	echo ""
	echo "Check Liveliness and Readiness of Mobile Foundation LiveUpdate component"
	./ibm-mobilefoundation/inventory/ibmcloudEnablement/files/install/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-3.1.3,component=liveupdate ui
	printReturnMsg $? liveupdate
fi

if [ "${mfpanalytics_recvr_enabled}" == "true" ]; then
	echo ""
	echo "Check Liveliness and Readiness of Mobile Foundation Analytics Receiver component"
	./ibm-mobilefoundation/inventory/ibmcloudEnablement/files/install/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-3.1.3,component=analytics-recvr ui
	printReturnMsg $? analytics-recvr
fi

if [ "${mfpanalytics_enabled}" == "true" ]; then
	echo ""
	echo "Check Liveliness and Readiness of Mobile Foundation Analytics component"
	./ibm-mobilefoundation/inventory/ibmcloudEnablement/files/install/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-3.1.3,component=analytics ui
	printReturnMsg $? analytics
fi

if [ "${mfpappcenter_enabled}" == "true" ]; then
	echo ""
	echo "Check Liveliness and Readiness of Mobile Foundation Application Center component"
	./ibm-mobilefoundation/inventory/ibmcloudEnablement/files/install/check_pods_ready.sh ${_SYSGEN_MF_NAMESPACE} helm.sh/chart=ibm-mobilefoundation-prod-3.1.3,component=appcenter ui
	printReturnMsg $? appcenter
fi

echo "Following are the mobile foundation components routes"

if [ "${mfpserver_enabled}" == "true" ]; then
	echo ""
	echo "MOBILE FOUNDATION_SERVER CONSOLE"
	oc get route -o jsonpath='{range .items[*]}{@.spec.host}{@.spec.path}{\"\\n\"}{end}' | grep mfpconsole
	echo ""
fi

if [ "${mfpanalytics_enabled}" == "true" ]; then
	echo ""
	echo "ANALYTICS CONSOLE"
	oc get route -o jsonpath='{range .items[*]}{@.spec.host}{@.spec.path}{\"\\n\"}{end}' | grep 'analytics' | grep -v 'service' | grep -v 'receiver'
fi

if [ "${mfpappcenter_enabled}" == "true" ]; then
	echo ""
	echo "APPLICATION CENTER CONSOLE"
	oc get route -o jsonpath='{range .items[*]}{@.spec.host}{@.spec.path}{\"\\n\"}{end}' | grep appcenterconsole
	echo ""
fi

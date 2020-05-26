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

printf "\nInstall procedure starting ...\n\n"

export CASE_FILES_DIR="./ibm-mobilefoundation/inventory/ibmcloudEnablement/files"

#  Following are to be used from the builtin ENV variables
export _SYSGEN_MF_NAMESPACE=${JOB_NAMESPACE}
export _GEN_DB2_NAMESPACE=mf-db2
export _GEN_ES_NAMESPACE=mf-elasticsearch

# export _SYSGEN_DOCKER_REGISTRY=${DOCKER_REGISTRY}
# export _SYSGEN_DOCKER_REGISTRY="cp.icr.io"
# export _SYSGEN_DOCKER_REGISTRY_USER=${DOCKER_REGISTRY_USER}
# export _SYSGEN_DOCKER_REGISTRY_PASSWORD=${DOCKER_REGISTRY_PASSWORD}

export _SYSGEN_DOCKER_REGISTRY="cp.stg.icr.io"
export _SYSGEN_DOCKER_REGISTRY_USER="iamapikey"
export _SYSGEN_DOCKER_REGISTRY_PASSWORD="lmTwt2gWsxJk25XAFATqGqkdWxWWOdsSfJhYL7Gomslo"

#  Mobile Foundation Image tag
export _GEN_IMG_TAG=8.1.0

#  Set image pull secret name
_GEN_IMG_PULLSECRET=mf-image-docker-pull

#  list all the components enabled
${CASE_FILES_DIR}/install/common/list_enabled_components.sh

#  validate inputs
${CASE_FILES_DIR}/install/common/input_validations.sh
if [ $? -ne 0 ]; then
	printf "\nInput validation failed. Exiting ...\n"
	exit $RC
fi

#  create pull secret
echo "Creating image pull secret for Mobile Foundation..."
oc create secret docker-registry ${_GEN_IMG_PULLSECRET} -n ${_SYSGEN_MF_NAMESPACE} --docker-server=${_SYSGEN_DOCKER_REGISTRY} --docker-username=${_SYSGEN_DOCKER_REGISTRY_USER} --docker-password=${_SYSGEN_DOCKER_REGISTRY_PASSWORD}
oc secrets -n ${_SYSGEN_MF_NAMESPACE} link default ${_GEN_IMG_PULLSECRET} --for=pull

# Setup TLS secret
${CASE_FILES_DIR}/install/mf/setup_ingress_tls_secret.sh

#  deploy db operator
if [ "${mfpserver_enabled}" == "true" ] || [ "${mfpappcenter_enabled}" == "true" ]; then
	if [ "${db_persistence_storageClassName}" != "" ] || [ "${db_persistence_claimname}" != "" ]; then
		${CASE_FILES_DIR}/install/db2/db2_preinstall.sh
		${CASE_FILES_DIR}/install/common/deploy_operator.sh db2 ${_GEN_DB2_NAMESPACE} db2-image-docker-pull

		${CASE_FILES_DIR}/install/common/operators_availability_check.sh db2 ${_GEN_DB2_NAMESPACE} "DB2 Operator"
		if [ $? -ne 0 ]; then
			printf " Exiting..."
			exit $RC
		fi
	fi
fi

#  deploy es operator
if [ "${mfpanalytics_enabled}" == "true" ]; then
	${CASE_FILES_DIR}/install/es/es_preinstall.sh
	${CASE_FILES_DIR}/install/common/deploy_operator.sh es ${_GEN_ES_NAMESPACE} es-image-docker-pull

	${CASE_FILES_DIR}/install/common/operators_availability_check.sh es ${_GEN_ES_NAMESPACE} "Elasticsearch Operator"
	if [ $? -ne 0 ]; then
		printf " Exiting..."
		exit $RC
	fi
fi

#  deploy mf operator
${CASE_FILES_DIR}/install/common/deploy_operator.sh mf ${_SYSGEN_MF_NAMESPACE} mf-image-docker-pull

${CASE_FILES_DIR}/install/common/operators_availability_check.sh mf ${_SYSGEN_MF_NAMESPACE} "Mobile Foundation Operator"
if [ $? -ne 0 ]; then
	printf " Exiting..."
	exit $RC
fi

#  Generate DB secret
if [ "${mfpserver_enabled}" == "true" ] || [ "${mfpappcenter_enabled}" == "true" ]; then
	if [ "${db_persistence_storageClassName}" != "" ] || [ "${db_persistence_claimname}" != "" ]; then
		${CASE_FILES_DIR}/install/mf/generate_db_secrets.sh db2inst1 db2inst1
	else
		${CASE_FILES_DIR}/install/mf/generate_db_secrets.sh ${db_userid} ${db_password}
	fi
fi

#  Create console login secret
${CASE_FILES_DIR}/install/common/generate_consolelogin_secrets.sh

if [ "${mfpanalytics_enabled}" == "true" ]; then
	#  Adding deployment values for ES
	${CASE_FILES_DIR}/install/common/add_deployment_values.sh es

	# deploy ES CR
	${CASE_FILES_DIR}/install/common/deploy_cr.sh es ${_GEN_ES_NAMESPACE}
	RC=$?
	if [ $RC -ne 0 ]; then
		exit $RC
	else
		#  Check ES services availability
		${CASE_FILES_DIR}/install/common/availability_check.sh es
	fi
fi

if [ "${mfpserver_enabled}" == "true" ] || [ "${mfpappcenter_enabled}" == "true" ]; then
	#  Adding deployment values for ES
	${CASE_FILES_DIR}/install/common/add_deployment_values.sh db2

	# deploy db2 CR
	${CASE_FILES_DIR}/install/common/deploy_cr.sh db2 ${_GEN_DB2_NAMESPACE}
	RC=$?
	if [ $RC -ne 0 ]; then
		exit $RC
	else
		#  Check pod/services availability
		${CASE_FILES_DIR}/install/common/availability_check.sh db2
	fi
fi

if [ "${mfpserver_enabled}" == "true" ] || [ "${mfpappcenter_enabled}" == "true" ]; then
	#  check for db reachability/test connection
	${CASE_FILES_DIR}/install/mf/check_for_mf_database.sh "DB2"
	RC=$?
	if [ $RC -ne 0 ]; then
		echo "Exiting ..."
		exit $RC
	fi
fi

#  Adding deployment values for MF
${CASE_FILES_DIR}/install/common/add_deployment_values.sh

# deploy MF CR
${CASE_FILES_DIR}/install/common/deploy_cr.sh mf ${_SYSGEN_MF_NAMESPACE}
RC=$?
if [ $RC -ne 0 ]; then
	exit $RC
else
	#  Check MF services availability
	${CASE_FILES_DIR}/install/common/availability_check.sh mf
fi

#  Print routes
${CASE_FILES_DIR}/install/common/print_routes.sh

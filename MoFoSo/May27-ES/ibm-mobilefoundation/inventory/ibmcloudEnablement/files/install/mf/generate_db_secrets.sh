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

DB_USER=$1
DB_PASSWORD=$2

# Create/Switch Project for MF
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE}

printf "\nGenerating Mobile Foundation DB secret ...\n"

if [ "${mfpserver_enabled}" == "true" ] || [ "${mfppush_enabled}" == "true" ] || [ "${mfpliveupdate_enabled}" == "true" ] || [ "${mfpappcenter_enabled}" == "true" ]; then

	_GEN_DB_SECRET_NAME="mobilefoundation-db-secret"
	_GEN_DB_USERID_BASE64=$(echo -n "${DB_USER}" | base64)
	_GEN_DB_PASSWORD_BASE64=$(echo -n "${DB_PASSWORD}" | base64)

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

	oc apply --namespace ${_SYSGEN_MF_NAMESPACE} -f ${_GEN_DB_SECRET_NAME}.yaml

	RC=$?

	if [ $RC -ne 0 ]; then
		printf "\nMobile Foundation database secret creation failure.\n"
		exit $RC
	fi

	#rm -f ${_GEN_DB_SECRET_NAME}.yaml

fi

# Create/Switch Project for MF
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE}

echo "MF DB secret generation script completed ..."
echo "*********************************************************************************************************************"
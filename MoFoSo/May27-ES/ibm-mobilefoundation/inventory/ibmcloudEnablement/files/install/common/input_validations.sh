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

echo "Performing input validations..."

resourceInputValidation()
{
    VARIABLE_VALUE=$1
    if [[ ${VARIABLE_VALUE}  =~ ['\\!@#$%^&*()-+_'] ]]; then
  	    #echo "$VARIABLE_VALUE value must not contain '{}\\!@#$%^&*()_-+'"
	    echo 1
    else
        echo 0
    fi
}

printErrorMsg()
{
    VAR_NAME=$1
    printf "\nIncorrect value in deployment values.\n"
    printf "${VAR_NAME} contains non-numeric input. Ensure the right numeric input is specified.\n\n"
    exit 1;
}

#
# Check for any special characters within the console_route_prefix
# 
if [[ $ingress_subdomain_prefix =~ ^\. ]] || [[ $ingress_subdomain_prefix =~ ^\- ]]; 
then 
    printf "\nINGRESS_SUBDOMAIN_PREFIX (ingress_subdomain_prefix) value must not bein with dot or hyphen.\n"
	exit 1
fi

if [ "${ingress_subdomain_prefix: -1}" == "." ] || [ "${ingress_subdomain_prefix: -1}" == "-" ]
then
	printf "\nINGRESS_SUBDOMAIN_PREFIX (ingress_subdomain_prefix) value must not end with dot . or - character.\n"
	exit 1
fi

if [[ ${ingress_subdomain_prefix}  =~ ['\\!@#$%^&*()_+'] ]]; then
  	printf "\nINGRESS_SUBDOMAIN_PREFIX (ingress_subdomain_prefix) value must not contain '{}\\!@#$%^&*()_+'\n"
	exit 1
fi

#
# Check for inter component relationship and validate
# - Only Push cannot be enabled alone without enabling Server
#
if [ "${mfppush_enabled}" == "true" ] && [ "${mfpserver_enabled}" == "false" ]
then
	printf "\nServer component must be enabled to use Push. Set mfpserver_enabled to true."
    printf "\nExiting ...\n\n"
	exit 1
fi

# Only LiveUpdate cannot be enabled alone without enabling Server
if [ "${mfpliveupdate_enabled}" == "true" ] && [ "${mfpserver_enabled}" == "false" ]
then
	printf "\nServer component must be enabled to use LiveUpdate. Set mfpserver_enabled to true.\n"
	exit 1
fi

if [ "${mfpserver_enabled}" == "true" ] || [ "${mfpappcenter_enabled}" == "true" ]
then
    # embedded DB validations
    if [ "${db_host// }" == "" ]
    then
        echo "Database Host value (${db_host}) is empty. Validation for setting up the in-built DB2..."
        
        if [ "${db_persistence_storageClassName}" == "" ] && [ "${db_persistence_claimname}" == "" ]
        then
            printf "\nWhile using DB2, either StorageClass name or existing PVC must be set."
            exit 1
        fi

        ${CASE_FILES_DIR}/install/common/storage_validation.sh db2
        if [ $? -ne 0 ]; then
            printf "\nDB persistence setting validation failed. Exiting ...\n"
            exit $RC
        fi	
    fi
fi

if [ "${mfpanalytics_enabled}" == "true" ]
then

    if [ "${elasticsearch_persistence_storageClassName}" == "" ] && [ "${elasticsearch_persistence_claimname}" == "" ]
    then
        printf "\nWhile using Analytics, either StorageClass Name or existing PVC has to be set."
        printf "\n set correct values either for elasticsearch_persistence_storageClassName or elasticsearch_persistence_claimname."
	    exit 1
    fi  

	${CASE_FILES_DIR}/install/common/storage_validation.sh es
	if [ $? -ne 0 ]; then
		printf "\Elasticsearch persistence setting validation failed. Exiting ...\n"
		exit $RC
	fi	
fi


#
# DB Schema special character validation
# 
if [[ ${db_schema}  =~ ['\\!@#$%^&*()-+'] ]]
then
  	printf "\ndb_schema value must not contain '{}\\!@#$%^&*()-+'"
    printf "\nCorrect the DB SCHEMA NAME and try again. \n\n"
	exit 1
fi

#
# namespace special character validation
# 
if [[ ${db_namespace}  =~ ['\\!@#$%^&*()+'] ]]
then
  	printf "\ndb_schema value must not contain '{}\\!@#$%^&*()+'"
    printf "\nCorrect the deployment value - db_namespace and try again. \n\n"
	exit 1
fi

if [[ ${es_namespace}  =~ ['\\!@#$%^&*()+'] ]]
then
  	printf "\ndb_schema value must not contain '{}\\!@#$%^&*()+'"
    printf "\nCorrect the deployment value - es_namespace and try again. \n\n"
	exit 1
fi

#
# resource cpu/memory input validation
#

read -r -d '' DEPLOYMENT_VALUES << EOM
dbinit_resources_requests_cpu
dbinit_resources_requests_memory
dbinit_resources_limits_cpu
dbinit_resources_limits_memory
mfpserver_resources_requests_cpu
mfpserver_resources_requests_memory
mfpserver_resources_limits_cpu
mfpserver_resources_limits_memory
mfppush_resources_requests_cpu
mfppush_resources_requests_memory
mfppush_resources_limits_cpu
mfppush_resources_limits_memory
mfpliveupdate_resources_requests_cpu
mfpliveupdate_resources_requests_memory
mfpliveupdate_resources_limits_cpu
mfpliveupdate_resources_limits_memory
mfpanalytics_recvr_resources_requests_memory
mfpanalytics_recvr_resources_requests_memory
mfpanalytics_recvr_resources_limits_cpu
mfpanalytics_recvr_resources_limits_memory
mfpanalytics_resources_requests_cpu
mfpanalytics_resources_requests_memory
mfpanalytics_resources_limits_cpu
mfpanalytics_resources_limits_memory
mfpappcenter_resources_requests_cpu
mfpappcenter_resources_requests_memory
mfpappcenter_resources_limits_cpu
mfpappcenter_resources_limits_memory
elasticsearch_persistence_size
elasticsearch_data_resources_requests_cpu
elasticsearch_data_resources_requests_memory
elasticsearch_data_resources_limits_cpu
elasticsearch_data_resources_limits_memory
elasticsearch_master_resources_requests_cpu
elasticsearch_master_resources_requests_memory
elasticsearch_master_resources_limits_cpu
elasticsearch_master_resources_limits_memory
EOM

ERRORED_INPUTS=""

for DEPLOYMENT_VALUES in $(echo $VAR)
do
	RC=(resourceInputValidation ${!deploymentValue} $deploymentValue)
    if [ $RC -ne 0 ]
    then
        ERRORED_INPUTS = "${ERRORED_INPUTS}\n${deploymentValue}"
    fi

    COUNT_ERRORS=$(echo -e ${ERRORED_INPUTS} | sed '/^[[:space:]]*$/d' | wc -l)

    if [ $COUNT_ERRORS -ne 0 ]
    then
        echo "Correct the deployment values and try again."
        echo "Ensure the following deployment values for resource inputs are set correctly... "
        echo -e ${ERRORED_INPUTS}
        exit 1
    fi
done
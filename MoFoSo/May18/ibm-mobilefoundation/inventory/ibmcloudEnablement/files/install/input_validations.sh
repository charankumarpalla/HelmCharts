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

#
#  function to check is input a Number
#  Usage Pattern : if [ $(isNumber ${db_port}) -ne 0 ]; then printErrorMsg db_port; fi
isNumber() {
    NUMBER_ENTRY=$1
    re='^[0-9]+$'
    if ! [[ ${NUMBER_ENTRY} =~ $re ]]; then
        echo 1
    else
        echo 0
    fi
}

resourceInputValidation() {
    VARIABLE_VALUE=$1
    if [[ ${VARIABLE_VALUE} =~ ['\\!@#$%^&*()-+_'] ]]; then
        #echo "$VARIABLE_VALUE value must not contain '{}\\!@#$%^&*()_-+'"
        #echo "Correct the DB SCHEMA NAME and try again. Exiting..."
        echo 1
    else
        echo 0
    fi
}

printErrorMsg() {
    VAR_NAME=$1
    printf "\nIncorrect value in deployment values.\n"
    printf "${VAR_NAME} contains non-numeric input. Ensure the right numeric input is specified. Exiting ...\n\n"
    exit 1
}

#
# Check for any special characters within the console_route_prefix
#
# if [ $mf_console_route_prefix = \.* ] || [ $mf_console_route_prefix = \-* ]
# then
#     printf "\nCONSOLE_PREFIX (mf_console_route_prefix) value must not being with dot . character.\n"
# 	exit 1
# fi

# if [ "${mf_console_route_prefix: -1}" == "." ] || [ "${mf_console_route_prefix: -1}" == "-" ]
# then
# 	printf "\nCONSOLE_PREFIX (mf_console_route_prefix) value must not end with dot . or - character.\n"
# 	exit 1
# fi

# if [[ ${mf_console_route_prefix}  =~ ['\\!@#$%^&*()_+'] ]]; then
#   	printf "\nCONSOLE_PREFIX (mf_console_route_prefix) value must not contain '{}\\!@#$%^&*()_+'\n"
# 	exit 1
# fi

#
# Check for inter component relationship and validate
# - Only Push cannot be enabled alone without enabling Server
#
if [ "${mfppush_enabled}" == "true" ] && [ "${mfpserver_enabled}" == "false" ]; then
    printf "\nServer component must be enabled to use Push. Set mfpserver_enabled to true."
    printf "\nExiting ...\n\n"
    exit 1
fi

# - Only LiveUpdate cannot be enabled alone without enabling Server
if [ "${mfpliveupdate_enabled}" == "true" ] && [ "${mfpserver_enabled}" == "false" ]; then
    printf "\nServer component must be enabled to use LiveUpdate. Set mfpserver_enabled to true.\n"
    printf "\nExiting ...\n\n"
    exit 1
fi

#
# DB Schema special character validation
#
if [[ ${db_schema} =~ ['\\!@#$%^&*()-+'] ]]; then
    printf "\ndb_schema value must not contain '{}\\!@#$%^&*()-+'"
    printf "\nCorrect the DB SCHEMA NAME and try again. Exiting...\n\n"
    exit 1
fi

#
# resource cpu/memory input validation
#

resourceInputValidation ${dbinit_resources_requests_cpu}
resourceInputValidation ${dbinit_resources_requests_memory}
resourceInputValidation ${dbinit_resources_limits_cpu}
resourceInputValidation ${dbinit_resources_limits_memory}

resourceInputValidation ${mfpserver_resources_requests_cpu}
resourceInputValidation ${mfpserver_resources_requests_memory}
resourceInputValidation ${mfpserver_resources_limits_cpu}
resourceInputValidation ${mfpserver_resources_limits_memory}

resourceInputValidation ${mfppush_resources_requests_cpu}
resourceInputValidation ${mfppush_resources_requests_memory}
resourceInputValidation ${mfppush_resources_limits_cpu}
resourceInputValidation ${mfppush_resources_limits_memory}

resourceInputValidation ${mfpliveupdate_resources_requests_cpu}
resourceInputValidation ${mfpliveupdate_resources_requests_memory}
resourceInputValidation ${mfpliveupdate_resources_limits_cpu}
resourceInputValidation ${mfpliveupdate_resources_limits_memory}

resourceInputValidation ${mfpanalytics_recvr_resources_requests_cpu}
resourceInputValidation ${mfpanalytics_recvr_resources_requests_memory}
resourceInputValidation ${mfpanalytics_recvr_resources_limits_cpu}
resourceInputValidation ${mfpanalytics_recvr_resources_limits_memory}

resourceInputValidation ${mfpanalytics_resources_requests_cpu}
resourceInputValidation ${mfpanalytics_resources_requests_memory}
resourceInputValidation ${mfpanalytics_resources_limits_cpu}
resourceInputValidation ${mfpanalytics_resources_limits_memory}

resourceInputValidation ${mfpappcenter_resources_requests_cpu}
resourceInputValidation ${mfpappcenter_resources_requests_memory}
resourceInputValidation ${mfpappcenter_resources_limits_cpu}
resourceInputValidation ${mfpappcenter_resources_limits_memory}

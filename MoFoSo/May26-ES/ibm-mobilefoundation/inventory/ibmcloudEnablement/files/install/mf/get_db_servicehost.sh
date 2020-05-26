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

DB_SERVICETYPE=$1

if [ "${DB_SERVICETYPE}" == "db2-primary" ]
then
    # get db2 primary service host
    DB_SERVICE_NAME=$(oc get svc -n "${_GEN_DB_NAMESPACE}" -l app=db2-primary-ibm-db2u,chart=ibm-db2-prod,servicetype=mf-db2-primary -o json | jq .items[0].metadata.name | sed "s/\"//g")
else
    if [ "${db2_hadr_enabled}" == "true" ]
    then
        # get db2 hadr service host
        DB_SERVICE_NAME=$(oc get svc -n "${_GEN_DB_NAMESPACE}" -l app=db2-primary-ibm-db2u,chart=ibm-db2-prod,servicetype=mf-db2-hadr -o json | jq .items[0].metadata.name | sed "s/\"//g")
    else
        DB_SERVICE_NAME=""
    fi
fi

echo ${DB_SERVICE_NAME}
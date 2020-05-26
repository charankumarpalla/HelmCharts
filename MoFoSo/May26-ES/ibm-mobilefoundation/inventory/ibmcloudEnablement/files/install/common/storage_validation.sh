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

COMPONENT=$1

checkStorageSettings()
{
    persistence_storageClassName=$1
    persistence_claimname $2
    NAMESPACE $3

    # check if the storage class exists
    if [ "${persistence_storageClassName}" != "" ]
    then
        oc get sc ${persistence_storageClassName} >/dev/null 2>&1
        RC=$?
        if [ $RC -ne 0 ] ; then
            echo "Invalid StorageClass name (${persistence_storageClassName}) for the deployment value - ${COMPONENT}_persistence_storageClassName. Exiting ..."
            exit $RC
        fi
    fi

    # check the status of pvc 
    if [ "${persistence_claimname}" != "" ]
    then
        oc get pvc -n ${NAMESPACE} ${persistence_claimname} >/dev/null 2>&1
        RC=$?
        if [ $RC -ne 0 ] ; then
            echo "Persistent Volume Claim name (${persistence_claimname}) set for ${COMPONENT} doesn't exists. Exiting ..."
            exit $RC
        else
            PVC_STATUS=$(oc get pvc -n ${NAMESPACE} ${persistence_claimname} -o json | jq .status.phase | sed "s/\"//g")
            if [ "${PVC_STATUS}" != "Bound"]
            then
                echo "Persistent Volume Claim name (${persistence_claimname}) set for ${COMPONENT} is not in Bound status. Exiting ..."
                exit 1
            fi
        fi  
    fi
}

if [ "${COMPONENT}" == "db2" ]
then
    checkStorageSettings "${db_persistence_storageClassName}" "${db_persistence_claimname}" "${_GEN_DB2_NAMESPACE}"
fi

if [ "${COMPONENT}" == "es" ]
    checkStorageSettings "${elasticsearch_persistence_storageClassName}" "${elasticsearch_persistence_claimname}" "${_GEN_ES_NAMESPACE}"
fi
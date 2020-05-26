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

echo "Setup Ingress secret name ..."

if [ "${ingress_secret}" == "" ]
then 
    echo "Copying Ingress TLS secret name to the the MF namespace (${_SYSGEN_MF_NAMESPACE}) ..."
    oc get secret ${INGRESS_TLS_NAME} --namespace=${TLS_SRC_NS} --export -o yaml | oc apply --namespace=${_SYSGEN_MF_NAMESPACE} -f -
else
    echo "Using the custom ingress tls secret name : ${ingress_secret} "
    oc get secret ${ingress_secret} -n ${TLS_SRC_NS} >/dev/null 2>&1
    TLS_SECRET_EXISTS=$?

    if [ $TLS_SECRET_EXISTS -ne 0 ]
    then
        echo "Ingress TLS secret name ($ingress_secret) doesn't exists. Proceeding without ingress secret name ..."
    fi
fi


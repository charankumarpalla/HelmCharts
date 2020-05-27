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

NAME=$1

if ! oc get namespace "$NAME" > /dev/null 2>&1; then
    echo "\"$NAME\" namespace does not exist."
    exit 0
fi

CREATED_BY=$(oc get namespace $NAME -o jsonpath='{.metadata.annotations.ibm\.com/created-by}')
if [ "$CREATED_BY" != "MobileFoundation" ]; then
    echo "\"$NAME\" namespace created separately."
    exit 0
fi

oc delete project "$NAME"
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

NAMESPACE=$1
LABEL_QUERY=$2
LABEL_VALUE=$3

check_pod_status() {
  for POD_ENTRY in $PODS
  do
    POD=$(echo $POD_ENTRY | cut -d ':' -f1)
    PHASE=$(echo $POD_ENTRY | cut -d ':' -f2)
    CONDITIONS=$(echo $POD_ENTRY | cut -d ':' -f3)

    if [ "$PHASE" != "Running" ] && [ "$PHASE" != "Succeeded" ]; then
      return 1
    fi
    if [[ "$CONDITIONS" != *"Ready=True"* ]]; then
      return 1
    fi
  done
  return 0
}

JSONPATH='{range .items[*]}{@.metadata.name}:{@.status.phase}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'
PODS=$(oc get pods -n "$NAMESPACE" -l "$LABEL_QUERY" -o jsonpath="$JSONPATH")
if [ -z "$PODS" ]; then
    echo "The $LABEL_VALUE pods are not created. Check logs for details."
    exit 1
else
    if check_pod_status; then
        echo "All $LABEL_VALUE pods are running and are ready."
        exit 0
    else
        echo "The $LABEL_VALUE pods are not running. There might a problem that is preventing the pods from starting, or they might require additional time to start."
        echo
        echo "Run the following commands to examine the status of the pods:"
        for POD_ENTRY in $PODS
        do
          POD=$(echo $POD_ENTRY | cut -d ':' -f1)
          echo "oc -n \"$NAMESPACE\" describe pod \"$POD\""
          echo "oc -n \"$NAMESPACE\" logs \"$POD\" --all-containers"
        done
        echo
        echo "Once the problem is resolved or the pods start running, re-run the installer to complete the installation process."
        exit 1
    fi
fi
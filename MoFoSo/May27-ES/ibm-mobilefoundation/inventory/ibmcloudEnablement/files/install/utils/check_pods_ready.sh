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
COUNT=$4

POLL_COUNT=${COUNT:-60}

COMPONENT=$(echo $LABEL_QUERY | cut -f3 -d"=")

check_pod_status() {

  for (( i=1; i<=$POLL_COUNT; i++ ))
  do
    echo "Checking $COMPONENT pod status ($i/$POLL_COUNT)..."

    PODS=$(oc get pods -n "$NAMESPACE" -l "$LABEL_QUERY" -o jsonpath="$JSONPATH")
    if [ $? -ne 0 ]; then
      continue
    fi

    for POD_ENTRY in $PODS; do
      POD=$(echo $POD_ENTRY | cut -d ':' -f1)
      PHASE=$(echo $POD_ENTRY | cut -d ':' -f2)
      CONDITIONS=$(echo $POD_ENTRY | cut -d ':' -f3)

      if [ "$STATUS" == "ErrImagePull" ] || [ "$STATUS" == "CrashLoopBackOff" ]; then
        return 1
      fi

      if [ "$PHASE" != "Running" ] && [ "$PHASE" != "Succeeded" ]; then
        continue
      fi

      if [ "$PHASE" == "Pending" ]; then
        continue
      fi

      if [ "$PHASE" == "Running" ]; then
        if [[ "$CONDITIONS" == *"Ready=True"* ]]; then
          return 0
        fi
      fi
    done    
    sleep 10
  done

}

wait_for_pod() {

  JSONPATH='{range .items[*]}{@.metadata.name}:{@.status.phase}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'
  PODS=$(oc get pods -n "$NAMESPACE" -l "$LABEL_QUERY" -o jsonpath="$JSONPATH")
  if check_pod_status; then
    echo "All $COMPONENT pods are running and are ready."
    exit 0
  else
    echo "The $COMPONENT pods are not running. There might a problem that is preventing the pods from starting, or they might require additional time to start."
    echo
    echo "Run the following commands to examine the status of the pods:"
    for POD_ENTRY in $PODS; do
      POD=$(echo $POD_ENTRY | cut -d ':' -f1)
      echo "oc -n \"$NAMESPACE\" describe pod \"$POD\""
      echo "oc -n \"$NAMESPACE\" logs \"$POD\" --all-containers"
    done
    echo
    echo "Once the problem is resolved or the pods start running, re-run the installer to complete the installation process."
    exit 1
  fi

  if [ -z "$PODS" ]; then
    echo "The $COMPONENT pods are not created. Check the logs for details."
    exit 1
  fi

  echo "Timeout waiting for $COMPONENT pod to be ready."
  exit 1
}

wait_for_pod

oc logs -n ${NAMESPACE} --follow $POD
sleep 9
exit $(oc get pods -n ${NAMESPACE} ${POD} -o jsonpath="{.status.containerStatuses[0].state.terminated.exitCode}")

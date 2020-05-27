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

echo "Run the operator pod availability checks ..."

check_pod_status() {
  for i in {1..30}; do
    echo "Checking $LABEL_VALUE-operator pod status ($i/30)..."
    PODS=$(oc get pods -n "$NAMESPACE" -l "$LABEL_QUERY" -o jsonpath='{range .items[*]}{@.metadata.name}{":"}{@.status.phase}{"\n"}{end}')
    if [ $? -ne 0 ]; then
      continue
    fi
    for POD_ENTRY in $PODS; do
      POD=$(echo $POD_ENTRY | cut -d ':' -f1)
      STATUS=$(echo $POD_ENTRY | cut -d ':' -f2)

      if [ "$STATUS" == "ErrImagePull" ] || [ "$STATUS" == "CrashLoopBackOff" ]; then
        return 1
      fi

      if [ "$STATUS" != "Running" ] && [ "$STATUS" != "Succeeded" ]; then
        if [ $i == 30 ]; then
          return 1
        fi
      fi

      if [ "$STATUS" == "Running" ] || [ "$STATUS" == "Succeeded" ]; then
        return 0
      fi
    done
    sleep 10
  done
}

wait_for_pod() {
  sleep 5
  PODS=$(oc get pods -n "$NAMESPACE" -l "$LABEL_QUERY" -o jsonpath='{range .items[*]}{@.metadata.name}{":"}{@.status.phase}{"\n"}{end}')
  if [ -z "$PODS" ]; then
    echo "The $LABEL_VALUE operator pods are not created. Check logs for details."
    exit 1
  else
    if check_pod_status; then
      echo "All $LABEL_VALUE operator pods are running."
      exit 0
    else
      echo "The $LABEL_VALUE operator pods are not running. There might a problem that is preventing the pods from starting, or they might require additional time to start."
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
  fi

  echo "Timeout waiting for ${LABEL_VALUE}-operator pod to start."
  exit 1
}

wait_for_pod

oc logs -n ${NAMESPACE} --follow $POD
sleep 9
exit $(oc get pods -n ${NAMESPACE} ${POD} -o jsonpath="{.status.containerStatuses[0].state.terminated.exitCode}")

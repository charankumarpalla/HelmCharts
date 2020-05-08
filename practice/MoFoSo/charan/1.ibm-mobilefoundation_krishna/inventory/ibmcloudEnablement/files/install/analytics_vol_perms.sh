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
VOLNAME=$2

ANALYTICS_VOLUME_NAME="mfpanalytics-$VOLNAME"

read -r -d '' OVERRIDES_VAR << EOM
{
        "spec": {
            "containers": [
                {
                    "command": [
                        "/bin/sh",
                        "-c",
                        "mkdir -p /opt/ibm/wlp/usr/servers/mfpf-analytics/analyticsData && chown -R 1001:0 /opt/ibm/wlp/usr/servers/mfpf-analytics/analyticsData"
                    ],
                    "image": "alpine:3.2",
                    "name": "perms-pod",
                    "volumeMounts": [{
                        "mountPath": "/opt/ibm/wlp/usr/servers/mfpf-analytics/analyticsData",
                        "name": "pvc-data"
                    }]
                }
            ],        
            "volumes": [
                {
                    "name": "pvc-data",
                    "persistentVolumeClaim": {
                        "claimName": "$ANALYTICS_VOLUME_NAME"
                    }
                }
            ]
        }
}
EOM

oc run perms-pod --overrides="${OVERRIDES_VAR}"  --image=notused --restart=Never

RC=$?

if [ $RC -ne 0 ]; then
    echo "Failed to assign permission to the mount volume from external pod for Analytics."
    exit $RC
else
      wait_period=0
      while true
      do
            wait_period=$(($wait_period+5))
            if [ $wait_period -gt 60 ];then
                  
                  POD_STATUS_MSG=$(oc get pod perms-pod --output="jsonpath={.status.phase}")
                  if [ "$POD_STATUS_MSG" == "Succeeded" ]
                  then
                        break;
                  elif [ "$POD_STATUS_MSG" == "Failed" ]
                  then
                        echo "Failed to assign permission to the mount volume from external pod for Analytics."
                        oc delete --ignore-not-found pod perms_pod -n $NAMESPACE
                        exit 1
                  fi
            fi
      done
fi
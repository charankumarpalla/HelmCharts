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
REPO_URL=$2        #  {{ icpa.registry }}{{ icpa.mf.registryNamespace }}/mfpf-dbinit
MF_IMAGE_TAG=$3    #  {{ mfcr.spec.global.dbinit.tag }}
DB_TYPE=$4         #  {{ mfcr.spec.mfpserver.db.type }}
DB_HOST=$5         #  {{ mfcr.spec.mfpserver.db.host }}
DB_PORT=$6         #  {{ mfcr.spec.mfpserver.db.port }}
DB_NAME=$7         #  {{ mfcr.spec.mfpserver.db.name }}
DB_SECRET_TYPE=$8  #  server/appcenter/analytics/liveupdate/ar
DB_SECRET=$9       #  {{ mfcr.spec.mfpserver.db.secret }} or {{ mfcr.spec.mfpappcenter.db.secret }}

printJobDebugMsg()
{
      echo
      echo "Run the following commands to examine the status of the job:"
      echo "oc -n \"$NAMESPACE\" describe pod mfdb"
      echo "oc -n \"$NAMESPACE\" logs -f mfdb"
      echo
      echo "Once the problem is resolved, re-run the installer to complete the installation process."
}

isSecretExists()
{
      CHECK_SECRET=$1
      MSG=$(oc get secret ${CHECK_SECRET} -n ${NAMESPACE} 2> /dev/null)
      RC=$?
      echo $RC
}

if [ ! -z "$MFPF_DB_USERNAME" ]
then
      DB_USER=$MFPF_DB_USERNAME
      DB_PASSWORD=$MFPF_DB_PASSWORD
else
      # for MFP Server / Push Database 
      if [ ! -z "$MFPF_SERVER_DB_USERNAME" ]
      then
            DB_USER=$MFPF_SERVER_DB_USERNAME 
            DB_PASSWORD=$MFPF_SERVER_DB_PASSWORD
      fi

      # for Application Center Database
      if [ ! -z "$MFPF_APPCENTER_DB_USERNAME" ]
      then
            DB_USER=$MFPF_APPCENTER_DB_USERNAME 
            DB_PASSWORD=$MFPF_APPCENTER_DB_PASSWORD
      fi

      # for LiveUpdate Database
      if [ ! -z "$MFPF_LIVEUPDATE_DB_USERNAME" ]
      then
            DB_USER=$MFPF_LIVEUPDATE_DB_USERNAME 
            DB_PASSWORD=$MFPF_LIVEUPDATE_DB_PASSWORD
      fi

      # if db-secret exists decode
      if [ ! -z "$DB_SECRET" ]
      then
            # decode secret to test userid password 
            if [ "$DB_SECRET_TYPE" = "server" ]
            then
                  SRC=$(isSecretExists ${DB_SECRET})
                  if [ $SRC -ne 0 ]; then
                        echo "Secret : ${DB_SECRET} doesn't exists ... "
                        echo "DB credentials must be provided either through Secrets or Environment Variables."
                        echo ""
                        echo "Create the secret ${DB_SECRET} under \"${NAMESPACE}\" and re-run the installer to complete the installation process."
                        exit $SRC
                  else
                        DB_USER=$(oc get secrets/$DB_SECRET --template={{.data.MFPF_RUNTIME_DB_USERNAME}} | base64 -d)
                        RC=$?
                        if [ $RC -ne 0 ]; then
                              echo "MFP Server/Push DB secret has errors. Incorrect entries in the secret."
                              exit $RC 
                        fi

                        DB_PASSWORD=$(oc get secrets/$DB_SECRET --template={{.data.MFPF_RUNTIME_DB_PASSWORD}} | base64 -d)
                        RC=$?
                        if [ $RC -ne 0 ]; then
                              echo "MFP Server/Push DB secret has errors. Incorrect entries in the secret."
                              exit $RC 
                        fi
                  fi
            elif [ "$DB_SECRET_TYPE" = "appcenter" ]
            then
                  ARC=$(isSecretExists ${DB_SECRET})
                  if [ $ARC -ne 0 ]; then
                        echo "Secret : ${DB_SECRET} doesn't exists ... "
                        echo "DB credentials either has to provided through secrets or Envirvonment Variables."
                        echo ""
                        echo "Create the secret ${DB_SECRET} under \"${NAMESPACE}\" and re-run the installer to complete the installation process."
                        exit $ARC
                  else
                        DB_USER=$(oc get secrets/$DB_SECRET --template={{.data.MFPF_APPCNTR_DB_USERNAME}} | base64 -d)
                        RC=$?
                        if [ $RC -ne 0 ]; then
                              echo "AppCenter DB secret has errors. Incorrect entries in the secret."
                              exit $RC 
                        fi

                        DB_PASSWORD=$(oc get secrets/$DB_SECRET --template={{.data.MFPF_APPCNTR_DB_PASSWORD}} | base64 -d)
                        RC=$?
                        if [ $RC -ne 0 ]; then
                              echo "AppCenter DB secret has errors. Incorrect entries in the secret."
                              exit $RC 
                        fi
                  fi
            elif [ "$DB_SECRET_TYPE" = "liveupdate" ]
            then
                  LRC=$(isSecretExists ${DB_SECRET})
                  if [ $LRC -ne 0 ]; then
                        echo "Secret : ${DB_SECRET} doesn't exists ... "
                        echo "DB credentials either has to provided through secrets or Envirvonment Variables."
                        echo ""
                        echo "Create the secret ${DB_SECRET} under \"${NAMESPACE}\" and re-run the installer to complete the installation process."
                        exit $LRC
                  else
                        DB_USER=$(oc get secrets/$DB_SECRET --template={{.data.MFPF_LIVEUPDATE_DB_USERNAME}} | base64 -d)
                        RC=$?
                        if [ $RC -ne 0 ]; then
                              echo "LiveUpdate DB secret has errors. Incorrect entries in the secret."
                              exit $RC 
                        fi

                        DB_PASSWORD=$(oc get secrets/$DB_SECRET --template={{.data.MFPF_LIVEUPDATE_DB_PASSWORD}} | base64 -d)
                        RC=$?
                        if [ $RC -ne 0 ]; then
                              echo "LiveUpdate DB secret has errors. Incorrect entries in the secret."
                              exit $RC 
                        fi
                  fi
            fi
      fi

fi



# Construct JDBC URL
SET_DB_TYPE=$(echo $DB_TYPE| tr '[:lower:]' '[:upper:]')

case $SET_DB_TYPE in
  "DB2") 
        echo "DB_TYPE is DB2" ;
        JDBC_URL="jdbc:db2://${DB_HOST}:${DB_PORT}/${DB_NAME}" ;;
  "ORACLE") 
        echo "DB_TYPE is Oracle";
        echo "Oracle DB is not supported via icpa-installer" ;;
  "MYSQL") 
        echo "DB_TYPE is MySQL";
        echo "MySQL DB is not supported via icpa-installer" ;;
  *) 
        echo "Invalid / No input for DB_TYPE. Setting to DB2" ;
        DB_TYPE=DB2;
        JDBC_URL="jdbc:db2://${DB_HOST}:${DB_PORT}/${DB_NAME}";;
esac

oc run mfdb --image=${REPO_URL}:${MF_IMAGE_TAG} \
            --env="POD_NAMESPACE=${NAMESPACE}" \
            --overrides='{ "apiVersion": "v1", "spec": { "imagePullSecrets": [{"name": "icpa-pull-secret"}] } }' \
            --restart=Never \
            --command -- java -Dij.driver=com.ibm.db2.jcc.DB2Driver \
             -Dij.dburl=${JDBC_URL} -Dij.user=${DB_USER} \
             -Dij.password=${DB_PASSWORD} \
             -cp /opt/ibm/MobileFirst/mfpf-libs/mfp-ant-deployer.jar:/opt/ibm/MobileFirst/dbdrivers/db2jcc4.jar \
              com.ibm.worklight.config.helper.database.CheckDatabaseExistence db2
RC=$?

if [ $RC -ne 0 ]; then
    echo "Mobile Foundation Database Test connection failure. Exiting."  
    exit $RC
else
      wait_period=0
      while true
      do
            wait_period=$(($wait_period+5))
            if [ $wait_period -gt 60 ];then
                  POD_STATUS_MSG=$(oc get pod mfdb --output="jsonpath={.status.phase}")

                  if [ "$POD_STATUS_MSG" = "Succeeded" ]
                  then
                        oc logs mfdb | grep " exists."
                        if [ $? -eq 0 ]
                        then
                              echo "Database test connection successful."
                        else
                              echo ""
                              echo "Database test connection failed. Ensure Database details are set correctly."
                              #oc delete --ignore-not-found pod mfdb -n ${NAMESPACE}
                              printJobDebugMsg
                              
                              exit 1
                        fi
                        break;
                  elif [ "$POD_STATUS_MSG" = "Failed" ]
                  then
                        echo "Database test connection job failed. Ensure Database details are set correctly. "
                        #oc delete --ignore-not-found pod mfdb -n ${NAMESPACE}
                        printJobDebugMsg
                        
                        exit 1
                  fi
            fi
      done
fi
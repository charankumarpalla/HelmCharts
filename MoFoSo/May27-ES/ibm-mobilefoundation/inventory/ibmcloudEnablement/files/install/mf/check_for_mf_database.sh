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

echo "Test DB connection ..."

DB_TYPE=$1

if [ "${db_host// }" == "" ]
then
	echo "Getting the DB2 Servicehost name ..."
	_GEN_DB_SRV_NAME=$(${CASE_FILES_DIR}/install/mf/get_db_servicehost.sh "db2-primary")
	_GEN_DB_HADR_SRV_NAME=$(${CASE_FILES_DIR}/install/mf/get_db_servicehost.sh "db2-hadr")

	_GEN_DB_HOSTNAME="${_GEN_DB_SRV_NAME}.${_GEN_DB2_NAMESPACE}.svc"
	_GEN_DB_HADR_SRV_HOSTNAME="${_GEN_DB_HADR_SRV_NAME}.${_GEN_DB2_NAMESPACE}.svc"
else
	_GEN_DB_HOSTNAME=${db_host// }
fi

DB_HOST=${_GEN_DB_HOSTNAME}

printJobDebugMsg()
{
      echo
      echo "Run the following commands to examine the status of the job:"
      echo "oc -n \"${_SYSGEN_MF_NAMESPACE}\" describe pod mfdb"
      echo "oc -n \"${_SYSGEN_MF_NAMESPACE}\" logs -f mfdb"
      echo
      echo "Once the problem is resolved, re-run the installer to complete the installation process."
}

# Construct JDBC URL
SET_DB_TYPE=$(echo $DB_TYPE| tr '[:lower:]' '[:upper:]')

case $SET_DB_TYPE in
  "DB2") 
        echo "DB_TYPE is DB2" ;
        JDBC_URL="jdbc:db2://${DB_HOST}:${db_port}/${db_name}" ;;
  "ORACLE") 
        echo "DB_TYPE is Oracle";
        echo "Oracle DB is not supported via icpa-installer" ;;
  "MYSQL") 
        echo "DB_TYPE is MySQL";
        echo "MySQL DB is not supported via icpa-installer" ;;
  *) 
        echo "Invalid / No input for DB_TYPE. Setting to DB2" ;
        DB_TYPE=DB2;
        JDBC_URL="jdbc:db2://${DB_HOST}:${db_port}/${db_name}" ;;
esac

oc run mfdb --image=${_SYSGEN_DOCKER_REGISTRY}/cp/mfpf-dbinit:${_GEN_IMG_TAG} \
            --env="POD_NAMESPACE=${_SYSGEN_MF_NAMESPACE}" \
            --overrides='{ "apiVersion": "v1", "spec": { "imagePullSecrets": [{"name": "mf-image-docker-pull"}] } }' \
            --restart=Never \
            --command -- java -Dij.driver=com.ibm.db2.jcc.DB2Driver \
             -Dij.dburl=${JDBC_URL} -Dij.user=${db_userid} \
             -Dij.password=${db_password} \
             -cp /opt/ibm/MobileFirst/mfpf-libs/mfp-ant-deployer.jar:/opt/ibm/MobileFirst/dbdrivers/db2jcc4.jar \
              com.ibm.worklight.config.helper.database.CheckDatabaseExistence db2
RC=$?

if [ $RC -ne 0 ]; then
    echo "Mobile Foundation Database Test connection failure. Exiting..."  
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
                              sleep 4
                              oc delete pod mfdb -n ${_SYSGEN_MF_NAMESPACE}
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

echo "Test DB connection completed ..."
echo "*********************************************************************************************************************"
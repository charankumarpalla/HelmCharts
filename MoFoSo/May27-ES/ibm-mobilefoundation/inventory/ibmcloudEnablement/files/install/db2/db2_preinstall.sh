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

echo "Starting the db2_preinstall script ..."

# Create/Switch Project for DB2
${CASE_FILES_DIR}/install/utils/create_project.sh ${_GEN_DB2_NAMESPACE}

#  Set image pull secret name
_GEN_DB2_IMG_PULLSECRET=db2-image-docker-pull

echo "Creating image pull secret for DB2 ..."
#  create pull secret
oc create secret docker-registry ${_GEN_DB2_IMG_PULLSECRET} -n ${_GEN_DB2_NAMESPACE} --docker-server=${_SYSGEN_DOCKER_REGISTRY} --docker-username=${_SYSGEN_DOCKER_REGISTRY_USER} --docker-password=${_SYSGEN_DOCKER_REGISTRY_PASSWORD}
oc secrets -n ${_GEN_DB2_NAMESPACE} link default ${_GEN_DB2_IMG_PULLSECRET} --for=pull

# add version for the img tag(s)
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/db2/deploy/crds/charts_v1_db2operator_crd.yaml


# create CRD
oc create --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/crds/charts_v1_db2operator_crd.yaml

# create role
oc create --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/db2u-role.yaml

# create role-binding
oc create --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/db2u-rolebinding.yaml

# create SCC
oc create --namespace ${_GEN_DB2_NAMESPACE} -f ${CASE_FILES_DIR}/components/db2/deploy/db2u-scc.yaml

# Create/Switch Project for DB2
${CASE_FILES_DIR}/install/utils/create_project.sh ${_GEN_DB2_NAMESPACE}

# For using storage class for data persistance
if [ "${db2_storageClassName// }" != "" ]
then
    echo " Setting permission for the storage class ..."
    oc get no -l node-role.kubernetes.io/worker --no-headers -o name | xargs -I {} --  oc debug {} -- chroot /host sh -c 'grep "^Domain = slnfsv4.coms" /etc/idmapd.conf || ( sed -i "s/.*Domain =.*/Domain = slnfsv4.com/g" /etc/idmapd.conf; nfsidmap -c; rpc.idmapd )'
fi

# Create/Switch Project back to MF namespace
${CASE_FILES_DIR}/install/utils/create_project.sh ${_SYSGEN_MF_NAMESPACE}

echo "DB2 Preinstall completed ..."
echo "*********************************************************************************************************************"

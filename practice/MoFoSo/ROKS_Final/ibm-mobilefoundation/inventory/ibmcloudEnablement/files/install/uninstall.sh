#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2019. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

#
#  MAIN - EXEC STARTS HERE
#

printf "\nInstall procedure starting ...\n\n"

export _GEN_OPERATOR_IMG_TAG=1.0.15

CASE_FILES_DIR=./ibm-mobilefoundation/inventory/ibmcloudEnablement/files

CR_YAML="${CASE_FILES_DIR}/deploy/crds/charts_v1_mfoperator_cr.yaml"
OPERATOR_YAML="${CASE_FILES_DIR}/deploy/operator.yaml"
SA_YAML="${CASE_FILES_DIR}/deploy/service_account.yaml"

oc delete --namespace ${JOB_NAMESPACE} -f ${CR_YAML}
oc delete --namespace ${JOB_NAMESPACE} -f ${SA_YAML}
oc delete --namespace ${JOB_NAMESPACE} -f ${OPERATOR_YAML}

# create role
cat << EOF | oc delete --namespace ${JOB_NAMESPACE} -f -
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: null
  name: mf-operator
  labels:
    app.kubernetes.io/name: mf-operator
    app.kubernetes.io/instance: mf-instance
    app.kubernetes.io/managed-by: helm
    release: mf-operator-${_GEN_OPERATOR_IMG_TAG}
rules:
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  verbs:
  - '*'
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - '*'
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - '*'
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - '*'
- apiGroups:
  - networking.k8s.io
  resources:
  - networkpolicies
  verbs:
  - '*'
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - services
  verbs:
  - '*'
- apiGroups:
  - monitoring.coreos.com
  resources:
  - servicemonitors
  verbs:
  - get
  - create
- apiGroups:
  - apps
  resourceNames:
  - mf-operator
  resources:
  - deployments/finalizers
  verbs:
  - update
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - apps
  resources:
  - replicasets
  verbs:
  - get
- apiGroups:
  - charts.helm.k8s.io
  resources:
  - '*'
  verbs:
  - '*'
EOF

# create role-binding
cat << EOF | oc delete --namespace ${JOB_NAMESPACE} -f -
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: mf-operator
  labels:
    app.kubernetes.io/name: mf-operator
    app.kubernetes.io/instance: mf-instance
    app.kubernetes.io/managed-by: helm
    release: mf-operator-${_GEN_OPERATOR_IMG_TAG}
subjects:
- kind: ServiceAccount
  name: mf-operator
  namespace: ${JOB_NAMESPACE}
roleRef:
  kind: Role
  name: mf-operator
  apiGroup: rbac.authorization.k8s.io
EOF

# create SCC
cat << EOF | oc delete --namespace ${JOB_NAMESPACE} -f -
---
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: mf-operator
  labels:
    app.kubernetes.io/name: mf-operator
    app.kubernetes.io/instance: mf-instance
    app.kubernetes.io/managed-by: helm
    release: mf-operator-${_GEN_OPERATOR_IMG_TAG}
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: []
allowedFlexVolumes: []
defaultAddCapabilities: []
fsGroup:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seccompProfiles:
- docker/default
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
EOF

# create CRD
cat << EOF | oc delete --namespace ${JOB_NAMESPACE} -f -
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: mfoperators.mf.ibm.com
  labels:
    app.kubernetes.io/name: mf-operator
    app.kubernetes.io/instance: mf-instance
    app.kubernetes.io/managed-by: helm
    release: mf-operator-${_GEN_OPERATOR_IMG_TAG}
spec:
  group: mf.ibm.com
  names:
    kind: MFOperator
    listKind: MFOperatorList
    plural: mfoperators
    shortNames:
    - mf
    singular: mfoperator
  scope: Namespaced
  subresources:
    status: {}
  version: v1
  versions:
  - name: v1
    served: true
    storage: true
  validation:
    openAPIV3Schema:
      properties:
        apiVersion:
          type: string
        kind:
          type: string
        metadata:
          type: object
EOF
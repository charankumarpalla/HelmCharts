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

sed -i "s|_IMG_REPO_|${_SYSGEN_DOCKER_REGISTRY}|g" ${CASE_FILES_DIR}/components/mf/deploy/operator.yaml
sed -i "s|_IMG_TAG_|${_GEN_IMG_TAG}|g" ${CASE_FILES_DIR}/components/mf/deploy/operator.yaml
sed -i "s|_IMG_PULLSECRET_|mf-image-docker-pull|g" ${CASE_FILES_DIR}/components/mf/deploy/operator.yaml

# delete role
cat <<EOF | oc delete --namespace ${_SYSGEN_MF_NAMESPACE} -f -
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
    release: mf-operator-${_GEN_IMG_TAG}
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

# delete role-binding
cat <<EOF | oc delete --namespace ${_SYSGEN_MF_NAMESPACE} -f -
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: mf-operator
  labels:
    app.kubernetes.io/name: mf-operator
    app.kubernetes.io/instance: mf-instance
    app.kubernetes.io/managed-by: helm
    release: mf-operator-${_GEN_IMG_TAG}
subjects:
- kind: ServiceAccount
  name: mf-operator
  namespace: ${_SYSGEN_MF_NAMESPACE}
roleRef:
  kind: Role
  name: mf-operator
  apiGroup: rbac.authorization.k8s.io
EOF

# delete SCC
cat <<EOF | oc delete --namespace ${_SYSGEN_MF_NAMESPACE} -f -
---
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: mf-operator
  labels:
    app.kubernetes.io/name: mf-operator
    app.kubernetes.io/instance: mf-instance
    app.kubernetes.io/managed-by: helm
    release: mf-operator-${_GEN_IMG_TAG}
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

# delete operator
oc delete --namespace ${_SYSGEN_MF_NAMESPACE} -f ${CASE_FILES_DIR}/components/mf/deploy/operator.yaml

# delete CRD
cat <<EOF | oc delete --namespace ${_SYSGEN_MF_NAMESPACE} -f -
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: mfoperators.mf.ibm.com
  labels:
    app.kubernetes.io/name: mf-operator
    app.kubernetes.io/instance: mf-instance
    app.kubernetes.io/managed-by: helm
    release: mf-operator-${_GEN_IMG_TAG}
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

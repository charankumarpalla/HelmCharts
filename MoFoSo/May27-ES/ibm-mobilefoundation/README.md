# ibm-mobilefoundation
[IBM Mobile Foundation CASE]IBM Mobile Foundation is an integrated platform that helps you extend your business to mobile devices.

IBM Mobile Foundation Platform includes a comprehensive development environment, mobile-optimized runtime middleware, a private enterprise application store, and an integrated management and analytics console, all backed by various security mechanisms.

For more information: [IBM Mobile Foundation Documentation](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/)

# Introduction
This CASE provides a helm based operator to install IBM Mobile Foundation and helm based Db2 operator

# Details
This CASE contains a single inventory item:
- ibmMobileFoundationProd - a helm based operator for installing IBM Mobile Foundation

# Prerequisites
This CASE requires either IBM Cloud Private or Openshift

## PodSecurityPolicy Requirements
The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

## Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

# Resources Required
Minimum 1000m CPU and 2048Mi memory available for resource requests required for installing each component of Mobile Foundation

# Installing the CASE
Install Mobile Foundation using the IBM Cloud Pak for Applications installer. The installer provides commands to install/uninstall Mobile Foundation separately or as part of Cloud Pak for Apps.

# Configuration
- [Chart Readme](../../operators/mf-operator/helm-charts/ibm-mobilefoundation-prod/README.md) 

# Storage for DB2

 Create your desired Persistent Volume with the size specified in GB matching the size in the Persistent Volume Claim .Claim name to be provided in charts_ v1_db2operator_cr.yaml

# Storage for Mobile Foundation Analytics 
If using dynamic provisioning, PVs will automatically be created for your deployment if a StorageClass that exists is inputed in charts_ v1_ mfoperator_cr.yaml, otherwise if the field is left blank, the default StorageClass will be used as long as one is selected as default on the kubernetes cluster.
If not using dynamic provisioning, create your desired Persistent Volume with the size specified in GB matching the size in the Persistent Volume Claim (default 1GB)

# Limitations
- N/A
# Documentation

[IBM Mobile Foundation](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0)
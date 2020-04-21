# ibm-mobilefoundation
[IBM Mobile Foundation CASE]IBM Mobile Foundation is an integrated platform that helps you extend your business to mobile devices.

IBM Mobile Foundation Platform includes a comprehensive development environment, mobile-optimized runtime middleware, a private enterprise application store, and an integrated management and analytics console, all backed by various security mechanisms.

For more information: [IBM Mobile Foundation Documentation](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/)

# Introduction
This CASE provides a helm chart to install IBM Mobile Foundation.

# Details
This CASE contains a single inventory item:
- ibmMobileFoundationProd - a helm chart for installing IBM Mobile Foundation

# Prerequisites
This CASE requires either IBM Cloud Private or Openshift

## PodSecurityPolicy Requirements
The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

## SecurityContextConstraints Requirements
This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

# Resources Required
Minimum 1000m CPU and 2048Mi memory available for resource requests required for installing each component of Mobile Foundation

# Installing
This chart can be installed with helm using the following command

```
helm install --name [optional release name] --namespace [optional release namespace] ibm-mobilefoundation-prod-x.x.x.tgz --tls
```

# Configuration
- [Chart Readme](./inventory/ibmMobileFoundationProd/README.md) 

# Storage for Mobile Foundation Analytics 
If using dynamic provisioning, PVs will automatically be created for your deployment if a StorageClass that exists is inputed in values.yaml, otherwise if the values.yaml field is left blank, the default StorageClass will be used as long as one is selected as default on the kubernetes cluster.
If not using dynamic provisioning, create your desired Persistent Volume with the size specified in GB matching the size in the Persistent Volume Claim (default 1GB)

# Limitations
- N/A
# Documentation

[IBM Mobile Foundation](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0)
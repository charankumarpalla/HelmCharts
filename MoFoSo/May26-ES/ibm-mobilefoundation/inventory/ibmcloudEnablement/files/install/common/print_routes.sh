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

printf "\nFollowing are the Mobile Foundation components routes.\n"

if [ "${mfpserver_enabled}" == "true" ]; then
	printf "\nMOBILE FOUNDATION SERVER CONSOLE: "
	oc get route -o jsonpath='{range .items[*]}{@.spec.host}{@.spec.path}{"\n"}{end}' | grep 'mfpconsole'
fi

if [ "${mfpanalytics_enabled}" == "true" ]; then
	printf "\nANALYTICS CONSOLE: "
	oc get route -o jsonpath='{range .items[*]}{@.spec.host}{@.spec.path}{"\n"}{end}' | grep 'analytics' | grep -v 'service' | grep -v 'receiver'
fi

if [ "${mfpappcenter_enabled}" == "true" ]; then
	printf "\nAPPLICATION CENTER CONSOLE: "
	oc get route -o jsonpath='{range .items[*]}{@.spec.host}{@.spec.path}{"\n"}{end}' | grep 'appcenterconsole'
fi

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

#  list the components enabled
printf "\nFollowing are the Mobile Foundation components enabled\n"
[ "${mfpserver_enabled}" == "true" ] && printf " \n> Mobile Foundation Server"
[ "${mfppush_enabled}" == "true" ] && printf " \n> Push"
[ "${mfpliveupdate_enabled}" == "true" ] && printf " \n> LiveUpdate"
[ "${mfpanalytics_recvr_enabled}" == "true" ] && printf " \n> Analytics Receiver"
[ "${mfpanalytics_enabled}" == "true" ] && printf " \n> Mobile Foundation Analytics"
[ "${mfpappcenter_enabled}" == "true" ] && printf " \n> Application Center\n"
echo ""

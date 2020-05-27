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

switch_project() {
    local NAME=$1
    if oc project "$NAME" > /dev/null 2>&1; then
        echo "Switched to \"$NAME\" project."
    else
        oc new-project "$NAME" > /dev/null
        oc annotate ns "$NAME" --overwrite "ibm.com/created-by=MobileFoundation" > /dev/null
        echo "Created \"$NAME\" project."
    fi
}
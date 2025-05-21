#!/bin/bash
. /opt/CPshared/5.0/tmp/.CPprofile.sh
AUTOPROV_ACTION=$1
GW_NAME=$2
CUSTOM_PARAMETERS=$3
RULEBASE=$4
IDSHARINGGW=$5
RULEBASE_SH=$6

if [[ $AUTOPROV_ACTION == delete ]]
then
		exit 0
fi

if [[ $CUSTOM_PARAMETERS != IDSHARING ]];
then
	exit 0
fi

if [[ $CUSTOM_PARAMETERS == IDSHARING ]]
then

INSTALL_STATUS=1
INSTALL_STATUS_SH=1
POLICY_PACKAGE_NAME=$RULEBASE
POLICY_PACKAGE_NAME_SH=$RULEBASE_SH

	echo "Connection to API server"
	SID=$(mgmt_cli -r true login -f json | jq -r '.sid')
	GW_JSON_SH=$(mgmt_cli --session-id $SID show simple-cluster name $IDSHARINGGW -f json)
	GW_UID=$(echo $GW_JSON | jq '.uid')
	
	GW_UID_SH=$(echo $GW_JSON_SH | jq '.uid')

	echo "adding Sharing GW to the list and enabling sharing"

		mgmt_cli --session-id $SID set generic-object uid $GW_UID identityAwareBlade.idServerGateway.add $GW_UID_SH
		mgmt_cli --session-id $SID set generic-object uid $GW_UID identityAwareBlade.enableOtherGateways true

	echo "Publishing changes"
		mgmt_cli --session-id $SID set session new-name "adding IA for $GW_NAME"
		mgmt_cli --session-id $SID set session description "adding IA for $GW_NAME"
		mgmt_cli publish --session-id $SID

	echo "Install policy $POLICY_PACKAGE_NAME on $GW_NAME"
	echo "mgmt_cli --session-id $SID -f json install-policy policy-package $POLICY_PACKAGE_NAME targets $GW_UID"
		until [[ $INSTALL_STATUS != 1 ]]; do
			mgmt_cli --session-id $SID -f json install-policy policy-package $POLICY_PACKAGE_NAME targets $GW_UID
			INSTALL_STATUS=$?
		done

	echo "Policy Installed"

	echo "Install policy $POLICY_PACKAGE_NAME_SH on $IDSHARINGGW "
	echo "mgmt_cli --session-id $SID -f json install-policy policy-package $POLICY_PACKAGE_NAME_SH targets $GW_UID_SH"
		until [[ $INSTALL_STATUS_SH != 1 ]]; do
			mgmt_cli --session-id $SID -f json install-policy policy-package $POLICY_PACKAGE_NAME_SH targets $GW_UID_SH
			INSTALL_STATUS_SH=$?
		done

	echo "Policy Installed"

        echo "Logging out of session"
        mgmt_cli logout --session-id $SID

		exit 0
fi

exit 0

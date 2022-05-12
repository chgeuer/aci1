#!/bin/bash

userAssigentIdentitySegments=(${AZ_SCRIPTS_USER_ASSIGNED_IDENTITY//\// })
subscriptionId="${userAssigentIdentitySegments[1]}"
resourceGroupName="${userAssigentIdentitySegments[3]}"

access_token="$( curl --silent --get \
    --url "http://169.254.169.254/metadata/identity/oauth2/token" \
    --header "Metadata:true" \
    --data-urlencode "api-version=2018-02-01" \
    --data-urlencode "resource=https://management.azure.com" \
    --data-urlencode "bypass_cache=true" \
    | jq -r ".access_token" )"

rgjson="$( curl --silent --get \
  --url "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}" \
  --data-urlencode "api-version=2019-07-01" \
  --header "Authorization: Bearer ${access_token}" \
  )"

output="$( echo "{}" | \
  jq --arg x "${access_token}" '.access_token=$x' | \
  jq --arg x "${rgjson}" '.rgjson=($x | fromjson)' | \
  jq --arg x "${IDENTITY_HEADER}" '.IDENTITY_HEADER=$x' \
  )" 

echo "${output}" > $AZ_SCRIPTS_OUTPUT_PATH

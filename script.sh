#!/bin/bash -e

echo "Fuck fuck fuck"

echo "gr ${resourceGroupName} ${GREETINGS}"

instanceMetadataJson="$( curl --silent --get \
  --url "http://169.254.169.254/metadata/instance" \
  --data-urlencode "api-version=2021-12-13" \
  --header "Metadata:true" )"

subscriptionId="$( echo "${instanceMetadataJson}" | jq -r ".compute.subscriptionId" )"
echo "${subscriptionId}"
resourceGroupName="$( echo "${instanceMetadataJson}" | jq -r ".compute.resourceGroupName" )"
echo "${resourceGroupName}"
access_token="$( curl --silent --get \
    --url "http://169.254.169.254/metadata/identity/oauth2/token" \
    --header "Metadata:true" \
    --data-urlencode "api-version=2018-02-01" \
    --data-urlencode "resource=https://management.azure.com" \
    --data-urlencode "bypass_cache=true" \
    | jq -r ".access_token" )"
echo "${access_token}"

rgjson="$( curl --silent --get \
  --url "https://management.azure.com/subscriptions/${subscriptionId}/resourcegroups/${resourceGroupName}" \
  --data-urlencode "api-version=2019-07-01" \
  --header "Authorization: Bearer ${access_token}" \
  )"

output="$( echo "{}" | \
  jq --arg x "${access_token}" '.access_token=$x' | \
  jq --arg x "${instanceMetadataJson}" '.instanceMetadataJson=($x | fromjson)' | \
  jq --arg x "${rgjson}" '.rgjson=($x | fromjson)' \
  )" 

echo "${output}"

echo "${output}" > $AZ_SCRIPTS_OUTPUT_PATH

#!/bin/bash -e

bicep build azuredeploy.bicep
git commit -am "."
git push

cmd.exe /C "start $( echo "https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fchgeuer%2Faci1%2Fmaster%2Fazuredeploy.json" )"

#!/bin/bash -e

bicep build azuredeploy.bicep
git commit -am "."
git push

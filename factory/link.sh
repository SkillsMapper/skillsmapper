#!/bin/bash
mkdir -p chapter/images
ln -s ../skill-lookup/cloudbuild.yaml ./builds/skill-service-cloudbuild.yaml
ln -s /Users/danielvaughan/Development/git/book/cloud-native-development-with-google-cloud/images/factory.png chapter/images/factory.png
ln -s -f /Users/danielvaughan/Development/git/book/cloud-native-development-with-google-cloud/images/continuous-integration.png  chapter/images/continuous-integration.png
ln -s -f /Users/danielvaughan/Development/git/book/cloud-native-development-with-google-cloud/images/continuous-deployment.png chapter/images/continuous-deployment.png

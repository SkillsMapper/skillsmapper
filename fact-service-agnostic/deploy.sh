#!/usr/bin/env bash
envsubst < k8s-template/deployment.yaml > k8s/deployment.yaml
envsubst < k8s-template/serviceaccount.yaml > k8s/serviceaccount.yaml
skaffold run

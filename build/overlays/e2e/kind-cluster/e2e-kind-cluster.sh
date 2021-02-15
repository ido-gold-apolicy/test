#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Create kind cluster
kind create cluster --config "$DIR"/kind-config.yaml

# Use kind context
kubectl config use-context kind-kind

# Apply analyzer deployment
kubectl apply -f "$DIR"/node-analyzer.yaml

sleep 30
#!/usr/bin/env bash

# Exit immidiatly if a commad returns a non zero exit code
set -e
baseDir="$(readlink -f -- "$(dirname -- "$0")/../..")"

echo "***Running Proto ***"
# sh ../../build/buildproto.sh
echo "*** Finished Build Proto ***"

echo "*** Apply workloads yaml ***"
kubectl apply -f e2e-workloads.yaml
echo "*** Finished workloads yaml ***"

echo "*** Apply access yaml ***"
kubectl apply -f e2e-access.yaml
echo "*** Finished access yaml ***"

echo "*** Init SQL / MongoDB Containers ***"
sh ../../../build/dev.sh
echo "*** Finished Init SQL / MongoDB Containers ***"

echo "*** Applying db e2e data script ***"
docker exec mysql-dev mysql -u root -ppassword -e "$(cat ../../e2edata.sql)"

echo "*** Creating kind cluster ***"
./kind-cluster/e2e-kind-cluster.sh

echo "*** Applying db e2e data script ***"
docker exec mysql-dev mysql -u root -ppassword -e "$(cat ../../e2etasks.sql)"

echo "*** Start Deploy Skaffold ***"
kubectl config use-context docker-desktop
cd ../../..
skaffold  run --tail --no-prune=false --cache-artifacts=false --profile e2e


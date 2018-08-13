#!/usr/bin/env bash
set -o pipefail
set -o errexit
set -o nounset

echo $CA_CRT | base64 --decode -i > ${HOME}/ca.crt

kubectl config set-cluster \
	k8s-101 \
	--embed-certs=true \
	--server=${CLUSTER_ENDPOINT} \
	--certificate-authority=${HOME}/ca.crt

kubectl config set-credentials \
	travis-default \
	--token=$SA_TOKEN

kubectl config set-context \
	travis \
	--cluster=$CLUSTER_NAME \
	--user=travis-default \
	--namespace=default

kubectl config use-context travis

kubectl config current-context

kubectl apply -f ingress.yml

docker push $IMAGE_NAME:latest
docker push $IMAGE_NAME:$TRAVIS_BRANCH-$GIT_HASH

function cleanup {
	printf "Cleaning up...\n"
	rm -vf "${HOME}/ca.crt"
	printf "Cleaning done."
}

trap cleanup EXIT

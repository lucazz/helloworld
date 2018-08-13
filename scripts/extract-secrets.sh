#!/usr/bin/env bash
set -o pipefail
set -o errexit
set -o nounset

IFS=$'\n\t'

if [[ "$#" -ne 2 || "${1}" == '-h' || "${1}" == '--help' ]]; then
	cat >&2 <<"EOF"
extrach-secrets.sh extracts user credentials for you based on username and namespace.
USAGE:
	extrach-secrets.sh USER NAMESPACE
EXAMPLE
	extrach-secrets.sh travis-default default
EOF
	exit 1
fi


main(){
	USERNAME="${1}"
	NAMESPACE="${2}"
	SECRET_NAME=$(kubectl get sa ${USERNAME} --namespace ${NAMESPACE} -o json | jq -r .secrets[].name)
	CA_CRT=$(kubectl get secret $SECRET_NAME --namespace ${NAMESPACE} -o json | jq -r '.data["ca.crt"]')
	USER_TOKEN=$(kubectl get secret $SECRET_NAME --namespace ${NAMESPACE} -o json | jq -r '.data["token"]')
	CONTEXT=`kubectl config current-context`
	CLUSTER_NAME=`kubectl config get-contexts $CONTEXT | awk '{print $3}' | tail -n 1`
	CLUSTER_ENDPOINT=`kubectl config view -o jsonpath="{.clusters[?(@.name == \"$CLUSTER_NAME\")].cluster.server}"`

	echo "The cluster endpoint is: ${CLUSTER_ENDPOINT}"
	echo "The CA_CRT is: ${CA_CRT}"
	echo "The USER_TOKEN is: ${USER_TOKEN}"
}

main "${1}" "${2}"

#!/bin/bash
set -e
set -o xtrace
echo $(set)
echo

BRANCH=${GIT_BRANCH#*/}

docker build --pull=true -t ${APP_NAME}:${TAG} .

# Pushing Docker Image to Quay
echo "Pushing tag to Quay.io..."
docker push ${APP_NAME}:${TAG}

# Push Docker image to latest tag if on master branch
if [[ ${GIT_BRANCH#*/} == "master" ]]; then
	echo "Tagging image..."
	docker tag ${APP_NAME}:${TAG} ${APP_NAME}:latest

	echo "Pushing latest tag to Quay.io..."
	docker push ${APP_NAME}:latest

	echo "Removing local Docker latest image..."
	set +e
	docker rmi ${APP_NAME}:latest
	echo "Removed..."
fi

# Remove local image
echo "Removing local Docker git tagged images..."
set +e
docker rmi ${APP_NAME}:${TAG}

echo "Removed..."

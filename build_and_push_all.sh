#!/bin/bash

# Set your Docker Hub username or ACR registry
DOCKER_REPO="bharath1731" # or "<acr-name>.azurecr.io"

# Set your version number (e.g., v1.0.0)
VERSION="v1.0.0"

# List of services
SERVICES=("gateway" "service-a" "service-b" "service-c")

for SERVICE in "${SERVICES[@]}"; do
    echo "Building $SERVICE..."
    docker build -t $DOCKER_REPO/$SERVICE:$VERSION ./$SERVICE
    if [ $? -ne 0 ]; then
        echo "Build failed for $SERVICE"
        exit 1
    fi
    echo "Pushing $SERVICE..."
    docker push $DOCKER_REPO/$SERVICE:$VERSION
    if [ $? -ne 0 ]; then
        echo "Push failed for $SERVICE"
        exit 1
    fi
done

echo "All images built and pushed successfully!"
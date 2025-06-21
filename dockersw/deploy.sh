#!/bin/bash

# Load credentials from .env file
if [ -f .env ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

get_latest_dockerhub_tag() {
    repo="$1"
    curl -s "https://registry.hub.docker.com/v2/repositories/$repo/tags?page_size=1" | \
        grep -oP '"name":\s*"\K[^"]+' | head -1
}

get_latest_acr_tag() {
    acr_server="$1"
    repo="$2"
    token=$(curl -s -u "$ACR_USERNAME:$ACR_PASSWORD" "https://$acr_server/oauth2/token?service=$acr_server&scope=repository:$repo:pull" | jq -r .access_token)
    curl -s -H "Authorization: Bearer $token" "https://$acr_server/v2/$repo/tags/list" | jq -r '.tags[]' | sort -V | tail -1
}

echo "Where are your images stored?"
echo "1) Docker Hub"
echo "2) Azure Container Registry (ACR)"
read -p "Enter 1 or 2: " choice

if [ "$choice" == "1" ]; then
    if [ -z "$DOCKER_HUB_USERNAME" ] || [ -z "$DOCKER_HUB_PASSWORD" ]; then
        echo "Docker Hub credentials not set in .env"
        exit 1
    fi
    echo "$DOCKER_HUB_PASSWORD" | docker login --username "$DOCKER_HUB_USERNAME" --password-stdin
    if [ $? -ne 0 ]; then
        echo "Docker Hub login failed."
        exit 1
    fi

    echo "Deploy options:"
    echo "1) Deploy whole stack"
    echo "2) Deploy a single service"
    read -p "Enter 1 or 2: " deploy_choice

    if [ "$deploy_choice" == "1" ]; then
        # Fetch latest tags
        OCELOT_TAG=$(get_latest_dockerhub_tag "$DOCKER_HUB_USERNAME/ocelotgateway")
        SERVICEA_TAG=$(get_latest_dockerhub_tag "$DOCKER_HUB_USERNAME/servicea")
        SERVICEB_TAG=$(get_latest_dockerhub_tag "$DOCKER_HUB_USERNAME/serviceb")
        SERVICEC_TAG=$(get_latest_dockerhub_tag "$DOCKER_HUB_USERNAME/servicec")

        # Generate stack file with latest tags
        sed -e "s|OCELOT_TAG|$OCELOT_TAG|g" \
            -e "s|SERVICEA_TAG|$SERVICEA_TAG|g" \
            -e "s|SERVICEB_TAG|$SERVICEB_TAG|g" \
            -e "s|SERVICEC_TAG|$SERVICEC_TAG|g" \
            docker-stack-dockerhub.template.yml > docker-stack-dockerhub.yml

        echo "Deploying whole stack from Docker Hub with latest tags..."
        docker stack deploy -c docker-stack-dockerhub.yml mystack

    elif [ "$deploy_choice" == "2" ]; then
        echo "Which service do you want to deploy?"
        echo "1) ocelotgateway"
        echo "2) servicea"
        echo "3) serviceb"
        echo "4) servicec"
        read -p "Enter 1-4: " service_choice

        case "$service_choice" in
            1)
                SERVICE_NAME="ocelotgateway"
                TAG=$(get_latest_dockerhub_tag "$DOCKER_HUB_USERNAME/ocelotgateway")
                IMAGE="$DOCKER_HUB_USERNAME/ocelotgateway:$TAG"
                ;;
            2)
                SERVICE_NAME="servicea"
                TAG=$(get_latest_dockerhub_tag "$DOCKER_HUB_USERNAME/servicea")
                IMAGE="$DOCKER_HUB_USERNAME/servicea:$TAG"
                ;;
            3)
                SERVICE_NAME="serviceb"
                TAG=$(get_latest_dockerhub_tag "$DOCKER_HUB_USERNAME/serviceb")
                IMAGE="$DOCKER_HUB_USERNAME/serviceb:$TAG"
                ;;
            4)
                SERVICE_NAME="servicec"
                TAG=$(get_latest_dockerhub_tag "$DOCKER_HUB_USERNAME/servicec")
                IMAGE="$DOCKER_HUB_USERNAME/servicec:$TAG"
                ;;
            *)
                echo "Invalid service choice."
                exit 1
                ;;
        esac

        echo "Updating service $SERVICE_NAME to image $IMAGE..."
        docker service update --image "$IMAGE" mystack_$SERVICE_NAME

    else
        echo "Invalid deploy choice."
        exit 1
    fi

elif [ "$choice" == "2" ]; then
    if [ -z "$ACR_SERVER" ] || [ -z "$ACR_USERNAME" ] || [ -z "$ACR_PASSWORD" ]; then
        echo "ACR credentials not set in .env"
        exit 1
    fi
    echo "$ACR_PASSWORD" | docker login "$ACR_SERVER" --username "$ACR_USERNAME" --password-stdin
    if [ $? -ne 0 ]; then
        echo "ACR login failed."
        exit 1
    fi

    echo "Deploy options:"
    echo "1) Deploy whole stack"
    echo "2) Deploy a single service"
    read -p "Enter 1 or 2: " deploy_choice

    if [ "$deploy_choice" == "1" ]; then
        # Fetch latest tags (requires jq installed)
        OCELOT_TAG=$(get_latest_acr_tag "$ACR_SERVER" "ocelotgateway")
        SERVICEA_TAG=$(get_latest_acr_tag "$ACR_SERVER" "servicea")
        SERVICEB_TAG=$(get_latest_acr_tag "$ACR_SERVER" "serviceb")
        SERVICEC_TAG=$(get_latest_acr_tag "$ACR_SERVER" "servicec")

        # Generate stack file with latest tags
        sed -e "s|OCELOT_TAG|$OCELOT_TAG|g" \
            -e "s|SERVICEA_TAG|$SERVICEA_TAG|g" \
            -e "s|SERVICEB_TAG|$SERVICEB_TAG|g" \
            -e "s|SERVICEC_TAG|$SERVICEC_TAG|g" \
            docker-stack-acr.template.yml > docker-stack-acr.yml

        echo "Deploying whole stack from Azure Container Registry with latest tags..."
        docker stack deploy -c docker-stack-acr.yml mystack

    elif [ "$deploy_choice" == "2" ]; then
        echo "Which service do you want to deploy?"
        echo "1) ocelotgateway"
        echo "2) servicea"
        echo "3) serviceb"
        echo "4) servicec"
        read -p "Enter 1-4: " service_choice

        case "$service_choice" in
            1)
                SERVICE_NAME="ocelotgateway"
                TAG=$(get_latest_acr_tag "$ACR_SERVER" "ocelotgateway")
                IMAGE="$ACR_SERVER/ocelotgateway:$TAG"
                ;;
            2)
                SERVICE_NAME="servicea"
                TAG=$(get_latest_acr_tag "$ACR_SERVER" "servicea")
                IMAGE="$ACR_SERVER/servicea:$TAG"
                ;;
            3)
                SERVICE_NAME="serviceb"
                TAG=$(get_latest_acr_tag "$ACR_SERVER" "serviceb")
                IMAGE="$ACR_SERVER/serviceb:$TAG"
                ;;
            4)
                SERVICE_NAME="servicec"
                TAG=$(get_latest_acr_tag "$ACR_SERVER" "servicec")
                IMAGE="$ACR_SERVER/servicec:$TAG"
                ;;
            *)
                echo "Invalid service choice."
                exit 1
                ;;
        esac

        echo "Updating service $SERVICE_NAME to image $IMAGE..."
        docker service update --image "$IMAGE" mystack_$SERVICE_NAME

    else
        echo "Invalid deploy choice."
        exit 1
    fi

else
    echo "Invalid choice."
    exit 1
fi
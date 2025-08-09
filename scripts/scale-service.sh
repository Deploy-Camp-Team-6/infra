#!/bin/bash
# scripts/scale-service.sh

SERVICE_NAME=$1
REPLICAS=$2

if [ -z "$SERVICE_NAME" ] || [ -z "$REPLICAS" ]; then
    echo "Usage: $0 <service_name> <replicas>"
    exit 1
fi

docker service scale ${SERVICE_NAME}=${REPLICAS}
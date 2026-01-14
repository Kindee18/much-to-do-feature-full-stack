#!/bin/bash

# Docker Build Script for MuchToDo Backend
# This script builds the Docker image for the backend application

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="much-to-do"
IMAGE_TAG="latest"
DOCKERFILE="./Dockerfile"
BUILD_CONTEXT="."

echo -e "${YELLOW}[*] Starting Docker build process...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[!] Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Dockerfile exists
if [ ! -f "$DOCKERFILE" ]; then
    echo -e "${RED}[!] Dockerfile not found at $DOCKERFILE${NC}"
    exit 1
fi

# Build the Docker image
echo -e "${YELLOW}[*] Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}${NC}"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f "${DOCKERFILE}" "${BUILD_CONTEXT}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓] Docker image built successfully!${NC}"
    echo -e "${GREEN}[✓] Image: ${IMAGE_NAME}:${IMAGE_TAG}${NC}"
    
    # Show image details
    echo -e "${YELLOW}[*] Image details:${NC}"
    docker images | grep "${IMAGE_NAME}"
else
    echo -e "${RED}[!] Docker build failed!${NC}"
    exit 1
fi

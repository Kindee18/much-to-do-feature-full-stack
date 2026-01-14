#!/bin/bash

# Docker Run Script for MuchToDo Backend with Docker Compose
# This script runs the entire stack using docker-compose

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCKER_COMPOSE_FILE="./Server/MuchToDo/docker-compose.yaml"
ENV_FILE=".env"
PROJECT_NAME="much-todo"

echo -e "${YELLOW}[*] Starting Docker Compose stack...${NC}"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}[!] Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Check if docker-compose file exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}[!] docker-compose file not found at $DOCKER_COMPOSE_FILE${NC}"
    exit 1
fi

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}[!] .env file not found. Creating from .env.example...${NC}"
    if [ -f ".env.example" ]; then
        cp .env.example "$ENV_FILE"
        echo -e "${GREEN}[✓] Created .env from .env.example${NC}"
        echo -e "${YELLOW}[*] Please review and update .env with your configuration${NC}"
    else
        echo -e "${RED}[!] .env.example not found either. Please create .env manually.${NC}"
        exit 1
    fi
fi

# Start the stack
echo -e "${YELLOW}[*] Starting Docker Compose stack...${NC}"
docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$PROJECT_NAME" up -d --build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓] Docker Compose stack started successfully!${NC}"
    echo -e "${YELLOW}[*] Waiting for services to be ready...${NC}"
    sleep 5
    
    # Show running containers
    echo -e "${GREEN}[✓] Running containers:${NC}"
    docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$PROJECT_NAME" ps
    
    echo -e "${GREEN}[✓] Stack is ready!${NC}"
    echo -e "${YELLOW}[*] Services available at:${NC}"
    echo -e "    - Backend API: http://localhost:8080"
    echo -e "    - Mongo Express: http://localhost:8081"
    echo -e "    - Redis Commander: http://localhost:8082"
    echo ""
    echo -e "${YELLOW}[*] To view logs, run:${NC}"
    echo -e "    docker-compose -f $DOCKER_COMPOSE_FILE -p $PROJECT_NAME logs -f"
    echo ""
    echo -e "${YELLOW}[*] To stop the stack, run:${NC}"
    echo -e "    docker-compose -f $DOCKER_COMPOSE_FILE -p $PROJECT_NAME down"
else
    echo -e "${RED}[!] Docker Compose failed to start!${NC}"
    exit 1
fi

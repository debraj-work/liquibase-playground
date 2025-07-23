#!/bin/bash

# A script to run Liquibase migrations for a specific service.
# It should be executed from the same directory as the docker-compose.yaml file.

# --- Configuration ---
# The name of the Docker network created by docker-compose.
# This command dynamically gets the current directory name (e.g., "Downloads")
# and appends "_default", which is the standard docker-compose network name.
DOCKER_NETWORK=$(basename "$PWD")_default

# --- Script Logic ---

# Check if a service name was provided as an argument.
if [ -z "$1" ]; then
  echo "Error: No service name provided."
  echo "Usage: ./runner.sh <service_name>"
  echo "Example: ./runner.sh service1"
  exit 1
fi

SERVICE_NAME=$1
CHANGELOG_FILE=""
LOG_LEVEL=${2:-info}

# Determine the correct changelog file based on the input service name.
if [ "$SERVICE_NAME" == "service1" ]; then
  CHANGELOG_FILE="changelogs/service1_mysql_root_changelog.xml"
elif [ "$SERVICE_NAME" == "service2" ]; then
  CHANGELOG_FILE="changelogs/service2_mysql_root_changelog.xml"
else
  echo "Error: Invalid service name '$SERVICE_NAME'."
  echo "Please use 'service1' or 'service2'."
  exit 1
fi

# Check if the changelog file actually exists before running Docker.
if [ ! -f "changeLogs/$CHANGELOG_FILE" ]; then
    # Note: The path check is relative to the host, not the container.
    # The script expects to be run from ~/Downloads, so the path is changeLogs/changelogs/...
    # Let's correct the check to be relative to the script's location.
    # We assume the script is in ~/Downloads and changeLogs is also there.
    if [ ! -f "changeLogs/$(basename $CHANGELOG_FILE)" ]; then
         echo "Error: Changelog file not found for service '$SERVICE_NAME' at changeLogs/$(basename $CHANGELOG_FILE)"
         exit 1
    fi
fi


echo "-----------------------------------------------------"
echo "Running Liquibase migration for service: $SERVICE_NAME"
echo "Using changelog: $CHANGELOG_FILE"
echo "Connecting to network: $DOCKER_NETWORK"
echo "-----------------------------------------------------"

# Execute the Liquibase command in a Docker container.
docker run --rm --network="$DOCKER_NETWORK" \
  -v "$(pwd)/changeLogs:/liquibase/changelogs" \
  -e INSTALL_MYSQL=true \
  liquibase/liquibase:4.33 \
  --log-level="$LOG_LEVEL" \
  --url="jdbc:mysql://mysql_db:3306/mydatabase" \
  --username=user \
  --password=password \
  --changeLogFile="$CHANGELOG_FILE" \
  update

# Check the exit code of the docker command
if [ $? -eq 0 ]; then
  echo "✅ Liquibase update for $SERVICE_NAME completed successfully."
else
  echo "❌ Liquibase update for $SERVICE_NAME failed."
fi

#!/bin/bash
# get_logs.sh: A modular script to retrieve logs from pods in a given namespace.
#
# Usage:
#   ./get_logs.sh [-n namespace] [-p podName] [-c containerName] [-o output_file]
#
# Options:
#   -n  Specify the namespace (default: "gitlab")
#   -p  Specify a particular pod name (if not provided, logs for all pods are retrieved)
#   -c  Specify a container name (if provided, logs for that container are retrieved; only valid if -p is used or within all pods)
#   -o  Specify the output file (default: "log/logs.txt" in the script's directory)
#
# Examples:
#   # Retrieve logs for all pods in the default namespace "gitlab" and write to log/logs.txt:
#   ./get_logs.sh
#
#   # Retrieve logs for all pods in the "production" namespace, saving to log/production_logs.txt:
#   ./get_logs.sh -n production -o production_logs.txt
#
#   # Retrieve logs for a specific pod "my-pod" in "gitlab" namespace:
#   ./get_logs.sh -p my-pod
#
#   # Retrieve logs for a specific container "my-container" in pod "my-pod":
#   ./get_logs.sh -p my-pod -c my-container

set -e

# Determine the directory in which this script resides
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
LOG_DIR="${SCRIPT_DIR}/log"

# Create the log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Default values
NAMESPACE="gitlab"
POD=""
CONTAINER=""
# If the user does not supply an output file via -o, default to the log directory inside the script directory.
DEFAULT_OUTPUT_FILE="${LOG_DIR}/logs.txt"
OUTPUT_FILE="$DEFAULT_OUTPUT_FILE"

function usage {
  echo "Usage: $0 [-n namespace] [-p pod] [-c container] [-o output_file]"
  exit 1
}

# Parse command-line options
while getopts "n:p:c:o:" opt; do
  case $opt in
    n) NAMESPACE=$OPTARG ;;
    p) POD=$OPTARG ;;
    c) CONTAINER=$OPTARG ;;
    o) OUTPUT_FILE=$OPTARG ;;
    *) usage ;;
  esac
done

# Clear (or create) the output file
> "$OUTPUT_FILE"

echo "Namespace: $NAMESPACE" | tee -a "$OUTPUT_FILE"

# Function to retrieve logs from a given pod
function get_logs() {
  local podName=$1
  echo "--------------------------------------------------" | tee -a "$OUTPUT_FILE"
  echo "Pod: $podName" | tee -a "$OUTPUT_FILE"
  echo "--------------------------------------------------" | tee -a "$OUTPUT_FILE"
  
  if [ -n "$CONTAINER" ]; then
    echo "Retrieving logs for container '$CONTAINER' in pod '$podName'..." | tee -a "$OUTPUT_FILE"
    kubectl logs -n "$NAMESPACE" "$podName" -c "$CONTAINER" >> "$OUTPUT_FILE" 2>&1
  else
    kubectl logs -n "$NAMESPACE" "$podName" --all-containers=true >> "$OUTPUT_FILE" 2>&1
  fi

  echo "" | tee -a "$OUTPUT_FILE"
}

# Main logic: either process a specific pod or loop through all pods in the namespace
if [ -n "$POD" ]; then
  echo "Retrieving logs for pod '$POD' in namespace '$NAMESPACE'..." | tee -a "$OUTPUT_FILE"
  get_logs "$POD"
else
  echo "Retrieving logs for all pods in namespace '$NAMESPACE'..." | tee -a "$OUTPUT_FILE"
  PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
  for podName in $PODS; do
    get_logs "$podName"
  done
fi

echo "Logs have been saved to '$OUTPUT_FILE'."

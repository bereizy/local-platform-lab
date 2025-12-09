#!/bin/bash

echo "🛑 Stopping Local Platform Lab..."

# 1. Stop Minikube Cluster
# This pauses the containers but preserves the VM state and PVC data
minikube stop

echo ""
echo "✅ Environment stopped successfully."
echo "   - Data volume (Postgres) is PRESERVED."
echo "   - Registry images are PRESERVED."
echo ""
echo "💡 To resume, run: ./scripts/start-lab.sh"
echo "💡 To destroy everything (delete data), run: minikube delete"

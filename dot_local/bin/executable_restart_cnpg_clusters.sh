#!/usr/bin/env bash

# Script that reads in all cnpg clusters and restarts
# those whose pods have accumulated at least
# one container restart.

set -uo pipefail

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is not installed, exiting..."
  exit 1
fi

if ! kubectl cnpg version >/dev/null 2>&1; then
  echo "kubectl cnpg pluging not installed, exiting..."
  exit 1
fi

kubectl get clusters.postgresql.cnpg.io --all-namespaces --no-headers \
  -o custom-columns="NS:.metadata.namespace,NAME:.metadata.name" |
  while read -r ns name; do
    # Sum restart counts across all containers, across all pods for this cluster
    total_restarts=$(kubectl get pods -n "$ns" -l "cnpg.io/cluster=$name" \
      -o jsonpath='{range .items[*]}{range .status.containerStatuses[*]}{.restartCount}{"\n"}{end}{end}' |
      awk '{sum+=$1} END {print sum+0}')

    if [ "$total_restarts" -gt 0 ]; then
      echo "Cluster '$name' (ns: $ns) has $total_restarts restart(s), restarting..."
      if kubectl cnpg restart "$name" -n "$ns"; then
        echo "  OK"
      else
        echo "  FAILED (continuing with next cluster)"
      fi
    else
      echo "Cluster '$name' (ns: $ns) has 0 restarts, skipping."
    fi
  done

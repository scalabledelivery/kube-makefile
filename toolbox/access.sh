#!/bin/bash
NAMESPACE="${1}"
ACCESS_POD_NAME="${2}"
ACCESS_SHELL="${3}"
ACCESS_SVC_NAME="${4}"
ACCESS_SVC_PORT="${5}"

# note: do not chain [cond] && kubectl; because the last command doesn't show up in `job -l`
if [ "${ACCESS_SVC_NAME}" != "" ] && [ "${ACCESS_SVC_PORT}" != "" ]; then
    kubectl -n "${NAMESPACE}" port-forward "${ACCESS_SVC_NAME}" "${ACCESS_SVC_PORT}" 2>/dev/null 1>/dev/null &
fi

POD_NAME=$(kubectl -n "${NAMESPACE}" get pods | awk '{if($1 ~/^'${ACCESS_POD_NAME}'/) print $1}' | head -n1)
kubectl -n "${NAMESPACE}" exec -it "${POD_NAME}" -- "${ACCESS_SHELL}" || true

if [ "$(jobs -p)" != "" ]; then
    echo killing background jobs
    kill $(jobs -p)
fi
#!/usr/bin/env bash

# must have a k8s namespace env var
if [[ -z ${NS} ]]; then
    echo 'You must define the kubernetes namespace in an $NS env var like "set -x NS namespace".' >&2
    exit 1
fi

# setup tasks
mkdir -p data
MOODLE_DIR=/bitnami/moodle
POD=$(kubectl get pods -n ${NS} | grep 'moodle-' | cut -d ' ' -f 1)

if [[ -z ${POD} ]]; then
    echo "Unable to find a Moodle app pod in namespace ${NS}, are you sure that's right?" >&2
    echo "You may need to change the context between the GCP staging and production projects (see kubectl config get-contexts and kubectl config use-context). You won't be able to find a pod if you're using the staging namespace on the production context, for instance." >&2
    exit 1
fi

# nicely formatted JSON files thanks to jq
get_config () {
    echo "Getting configuration for $1 on Moodle pod ${POD} in namespace ${NS}"
    kubectl exec -n ${NS} ${POD} -it -- php ${MOODLE_DIR}/admin/cli/cfg.php --component=$1 --json | jq > data/$1.json
}

get_config 'core'

# full list of plugins with their own settings
# `moosh sql-run`` produces a bunch of garbage output so we have to strip it out
kubectl exec -n ${NS} ${POD} -it -- moosh -n --moodle-path=${MOODLE_DIR} sql-run 'SELECT DISTINCT plugin FROM {config_plugins}' | grep -o '=> .*' | tr -d '=> \r' > plugins.txt

for PLUGIN in $(cat plugins.txt); do
    get_config ${PLUGIN}
done

rm plugins.txt

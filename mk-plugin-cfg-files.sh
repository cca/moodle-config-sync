#!/usr/bin/env bash
# cull settings from a select set of plugins
# see also: get-all-cfgs.sh
PLUGINS=("assign" "auth_db" "auth_manual" "backup" "enrol_manual" "enrol_database" "enrol_meta" "enrol_self" "enrol_guest" "enrol_cohort" "auth_cas" "block_attendance" "block_point_view" "format_grid" "local_course_template" "mod_attendance" "mod_zoom" "report_customsql" "restore")

mkdir -p data
POD=$(kubectl get pods -n ${NS} | grep 'moodle-' | cut -d ' ' -f 1)

for PLUGIN in ${PLUGINS[@]}; do
    kubectl exec -n ${NS} ${POD} -it -- php /bitnami/moodle/admin/cli/cfg.php --component=$1 --json | jq > data/$1.json
done

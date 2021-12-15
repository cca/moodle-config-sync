#!/usr/bin/env bash
# cull settings from a select set of plugins
# see also: get-all-cfgs.sh
PLUGINS=(
    "assign"
    "assignfeedback_comments"
    "assignfeedback_editpdf"
    "assignfeedback_file"
    "assignfeedback_offline"
    "assignsubmission_comments"
    "assignsubmission_file"
    "assignsubmission_onlinetext"
    "attendance"
    "auth_cas"
    "auth_db"
    "backup"
    "block_myoverview"
    "block_panopto"
    "block_sharing_cart"
    "core_admin"
    "editor_atto"
    "enrol_database"
    "enrol_guest"
    "enrol_manual"
    "enrol_meta"
    "format_grid"
    "format_topcoll"
    "local_course_template"
    "report_customsql"
    "restore"
    "scheduler"
    "zoom"
)

mkdir -p data
POD=$(kubectl get pods -n ${NS} | grep 'moodle-' | cut -d ' ' -f 1)

for PLUGIN in ${PLUGINS[@]}; do
    kubectl exec -n ${NS} ${POD} -it -- php /bitnami/moodle/admin/cli/cfg.php --component=$1 --json | jq > data/$1.json
done

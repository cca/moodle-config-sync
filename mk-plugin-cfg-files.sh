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
    "fileconverter_googledrive"
    "format_grid"
    "format_topcoll"
    "googledocs"
    "label"
    "local_course_template"
    "media_videojs"
    "message"
    "mod_lesson"
    "mod_scheduler"
    "moodlecourse"
    "page"
    "qtype_multichoice"
    "question"
    "quiz"
    "report_customsql"
    "resource"
    "restore"
    "scorm"
    "tool_dataprivacy"
    "tool_log"
    "tool_recyclebin"
    "url"
    "workshop"
    "workshopallocation_random"
    "workshopeval_best"
    "workshopform_numerrors"
    "zoom"
)

mkdir -p data
POD=$(kubectl get pods -n ${NS} | grep 'moodle-' | cut -d ' ' -f 1)

for PLUGIN in ${PLUGINS[@]}; do
    echo "Getting configuration for plugin ${PLUGIN} on pod ${POD} in namespace ${NS}"
    kubectl exec -n ${NS} ${POD} -it -- php /bitnami/moodle/admin/cli/cfg.php --component=${PLUGIN} --json | jq > plugins/${PLUGIN}.json
done

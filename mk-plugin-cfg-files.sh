#!/usr/bin/env bash
PLUGINS=("auth_db" "auth_manual" "enrol_manual" "enrol_database" "enrol_meta" "enrol_self" "enrol_guest" "enrol_cohort" "auth_cas" "block_attendance" "block_point_view" "format_grid" "local_course_template" "mod_attendance" "mod_zoom" "report_customsql")

for PLUGIN in ${PLUGINS[@]}; do
    sudo php /opt/moodle38/admin/cli/cfg.php --component=${PLUGIN} --json > ~/${PLUGIN}.json
done

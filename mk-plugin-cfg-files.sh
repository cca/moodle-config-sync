#!/usr/bin/env bash
# this SQL "SELECT DISTINCT plugin FROM `mdl_config_plugins`" helps list all the
# possible values here, I do not recommend adding all of them however as there
# are many (>400) and some are inconsequential
PLUGINS=("assign" "auth_db" "auth_manual" "backup" "enrol_manual" "enrol_database" "enrol_meta" "enrol_self" "enrol_guest" "enrol_cohort" "auth_cas" "block_attendance" "block_point_view" "format_grid" "local_course_template" "mod_attendance" "mod_zoom" "report_customsql" "restore")

for PLUGIN in ${PLUGINS[@]}; do
    sudo php /opt/moodle38/admin/cli/cfg.php --component=${PLUGIN} --json > ~/${PLUGIN}.json
done

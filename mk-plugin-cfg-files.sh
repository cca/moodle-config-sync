#!/usr/bin/env bash
PLUGINS=("block_attendance" "block_point_view" "format_grid" "local_course_template" "mod_attendance" "mod_zoom" "report_customsql")

for PLUGIN in ${PLUGINS[@]}; do
    sudo php /opt/moodle38/admin/cli/cfg.php --component=${PLUGIN} --json > ~/${PLUGIN}.json
done

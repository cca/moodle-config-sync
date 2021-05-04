#!/usr/bin/env bash
# run from within the Moodle root, creates a "configs" folder of JSON data under
# your user's home directory
mkdir ~/configs

get_config () {
    sudo -u www-data php admin/cli/cfg.php --component=$1 --json > ~/configs/$1.json
}

get_config 'core'

# full list of plugins with their own settings
# sql-run produces a bunch of garbage output so we have to strip it out
moosh -n sql-run 'SELECT DISTINCT plugin FROM {config_plugins}' | grep -o '=> .*' | tr -d '=> ' > plugins.txt

for PLUGIN in $(cat plugins.txt); do
    get_config $PLUGIN
done

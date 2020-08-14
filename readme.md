# Moodle Config Sync

Synchronize configuration between instances, skipping certain values which should not be changed.

## Core

Replace `$MOODLE_DIR` with the directory that Moodle's code is in, note that this path may differ between your Moodle instances. Also assumes ssh aliases of `moodle` and `moodle-dev` for the two instances.

1. obtain a JSON copy of the configuration file using Moodle's included cfg.php command, `ssh moodle; sudo php $MOODLE_DIR/admin/cli/cfg.php --json > ~/config.json` then `scp moodle:~/config.json .`
1. read through the configuration properties and create a JSON array in a file named "skip.json" of properties you _don't_ want synchronized
    + for instance, all timestamp values, server-specific information, and database settings
    + it may be helpful to do step 1 on the dev server too, format the JSON files so they have a property on each line, then compare the two files e.g. `git diff config.json dev.config.json`
    + there's an example included here
1. copy these files to a dev server `rsync -avz . moodle-dev:$MOODLE_DIR/admin/cca_cli/cfg-sync`
1. run the script on the server, writing output to a log file `cd $MOODLE_DIR; sudo php admin/cca_cli/cfg-sync/core.php >> /var/log/moodle/core-cfg-sync.log`

## Additional Plugins

For plugins the process is similar:

1. obtain JSON configuration files for _all_ the plugins
    + try using "mk-plugin-cfg-files.sh" on the server to iterate through a list of plugins, you have to write a list of plugins into the script
    + can download them all at once with `rsync -avz moodle:'~/*.json' plugins/` (note: will also download any config.json file you have left in your home folder)
    + create a single plugins/skip.json file of nested arrays of skip lists for each plugin (the "version" property for each plugin will be automatically skipped)
1. copy these files to a dev server `rsync -avz . moodle-dev:$MOODLE_DIR/admin/cca_cli/cfg-sync`
1. run the plugins script, `cd $MOODLE_DIR; sudo php admin/cca_cli/cfg-sync/plugins.php >> /var/log/moodle/plugins-cfg-sync.log`

example plugins/skip.json:
```json
{
    "mod_attendance": ["search_activity_indexingend", "search_activity_indexingstart"],
    "mod_zoom": ["last_call_made_at"]
}
```

Moodle defines much vital functionality, such as authentication and enrollment, in plugins. A core configuration sync is not be enough to replicate an instance's settings.

## A note on "Custom site defaults"

Should we be using [Custom site defaults](https://docs.moodle.org/39/en/Administration_via_command_line#Custom_site_defaults) for this instead? This is a file local/defaults.php which specifies default settings like so:

```php
$defaults['pluginname']['settingname'] = 'settingvalue'; // for plugins
$defaults['moodle']['settingname'] = 'settingvalue';     // for core settings
```

as I see it, this poses a problem because we usually don't _know_ the default we want, we either want to copy something from another server or leave it as it is. It is easier to generate a JSON configuration file with cfg.php than it would be to create a local/defaults.php file. This is also only used during upgrades while we may want to sync settings in between upgrades.

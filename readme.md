# Moodle Config Sync

Synchronize configuration between Moodle instances, skipping certain values which should not be changed.

Our Moodle setup uses the [Bitnami Moodle](https://bitnami.com/stack/moodle) container in a kubernetes cluster. You can see the GitLab [CCA Moodle](https://gitlab.com/california-college-of-the-arts/cca-moodle) project for more details. For the purposes of this project, this means we can assume all our Moodle directories are /bitnami/moodle and we have `moosh` installed on our containers.

## Download JSON configuration files

Run `./get-all-cfgs.sh` to download all configuration files. Requires `jq` simply to format the JSON.

 1. Download `kubectl` and configure it to work with our cloud projects
 1. Set an `NS` namespace environment variable like `moodle-staging` (note: not a real namespace)
 1. Run `./get-all-cfgs.sh`
 1. Config files are downloaded to the "data" directory, you may want to move them into a subdirectory

You can repeat this process for multiple Moodle instances by changing the cloud context and namespace each time.

## Applying configurations

Use an array of setting names in skip.json to define core settings you _do not_ want to sync between instances, and then a second skip.json file for all plugins in the "plugins" directory. Example plugins/skip.json:

```json
{
    "attendance": ["search_activity_indexingend", "search_activity_indexingstart"],
    "zoom": ["last_call_made_at"]
}
```

Moodle defines much vital functionality, such as authentication and enrollment, in plugins. A core configuration sync is not be enough to replicate an instance's settings. You can see a compete list of plugin names with `SELECT DISTINCT plugin FROM {config_plugins}` but there are over four hundred of them and some are inconsequential.

Note that some plugins appear twice, like "zoom" and "mod_zoom". It seems like the name without the "mod" prefix is the one with all the meaningful settings.

**TBD** how to apply the modified configuration on another instance. Basically, sync the JSON config and skip files, then run the core.php and plugins.php scripts from this project on the container.

## A note on "Custom site defaults"

Should we be using [Custom site defaults](https://docs.moodle.org/310/en/Administration_via_command_line#Custom_site_defaults) for this instead? This is a file local/defaults.php which specifies default settings like so:

```php
$defaults['pluginname']['settingname'] = 'settingvalue'; // for plugins
$defaults['moodle']['settingname'] = 'settingvalue';     // for core settings
```

as I see it, this poses a problem because we usually don't _know_ the default we want, we either want to copy something from another server or leave it as it is. It is easier to generate a JSON configuration file with cfg.php than it would be to create a local/defaults.php file. This is also only used during upgrades while we may want to sync settings in between upgrades.

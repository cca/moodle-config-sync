# Moodle Config Sync

Synchronize configuration between Moodle instances, skipping certain values which should not be changed.

Our Moodle setup uses the [Bitnami Moodle](https://bitnami.com/stack/moodle) container in a kubernetes cluster. You can see the GitLab [CCA Moodle](https://gitlab.com/california-college-of-the-arts/cca-moodle) project for more details. For the purposes of this project, this means we can assume all our Moodle directories are /bitnami/moodle and we have `moosh` installed on our containers.

## Downloading JSON configuration files

Moodle defines much vital functionality, such as authentication and enrollment, in plugins. A core configuration sync is not enough to replicate an instance's settings. Use `SELECT DISTINCT plugin FROM {config_plugins}` to see a full list, but there are over four hundred of them and some are inconsequential. A number have only a useless `version` field. Some plugins appear twice, like "zoom" and "mod_zoom". It seems like the name without the "mod" prefix is the one with meaningful settings.

Run `./get-all-cfgs.sh` to download _all_ configuration files from an instance. Requires `jq` to format the JSON.

 1. Download `kubectl` and configure it to work with our cloud projects
 1. Set an `NS` namespace environment variable like `moodle-staging` (note: not a real namespace)
 1. Run `./get-all-cfgs.sh`
 1. Config files are downloaded to the "data" directory, there is one "core.json" and one for each of the many Moodle plugins, we may want to move them into a subdirectory

We can repeat this process for multiple Moodle instances by changing the cloud context and namespace each time. It's helpful to `diff` the JSON from two instances to determine what's worth synchronizing. Once we've identified which plugins to sync, write their names into the array at the top of "mk-plugin-cfg-files.sh", then run that script to download them from the origin (usually production) instance.

## Applying configurations

Use an array of setting names in skip.json to define core settings you _do not_ want to sync between instances, and then a second skip.json file for all the plugins we downloaded to the "plugins" directory. Example plugins/skip.json:

```json
{
    "attendance": ["search_activity_indexingend", "search_activity_indexingstart"],
    "zoom": ["last_call_made_at"]
}
```

Finally, sync the JSON config, skip files, and PHP scripts to the destination (usually dev) server. Then run the core.php and plugins.php scripts on the container.

## Additional synchronization

We cannot sync the settings for an OAuth 2 Service (typically used for Google integrations) so we have to set that up manually at /admin/tool/oauth2/issuers.php

File repository order and activation /admin/repository.php are not represented in the typical settings so synchronizing those needs to be done manually.

We do not synchronize the Boost Theme settings /admin/settings.php?section=themesettingboost and Additional HTML /admin/settings.php?section=additionalhtml so they can differ (e.g. having a warning label on non-production servers).

We do not sync the Moodle Mobile App settings since we don't want app users accidentally signing into dev.

## A note on "Custom site defaults"

Should we be using [Custom site defaults](https://docs.moodle.org/310/en/Administration_via_command_line#Custom_site_defaults) for this instead? This is a file local/defaults.php which specifies default settings like so:

```php
$defaults['pluginname']['settingname'] = 'settingvalue'; // for plugins
$defaults['moodle']['settingname'] = 'settingvalue';     // for core settings
```

as I see it, this poses a problem because we usually don't _know_ the default we want, we either want to copy something from another server or leave it as it is. It is easier to generate a JSON configuration file with cfg.php than it would be to create a local/defaults.php file. This is also only used during upgrades while we may want to sync settings in between upgrades.

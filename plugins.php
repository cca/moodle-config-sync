<?php

// Synchronize plugin configuration settings from specially-named JSON files.

/**
 *
 * @package    core
 * @subpackage cli
 * @copyright  2021 CCA (https://cca.edu)
 * @license    https://opensource.org/licenses/ECL-2.0 ECL 2.0
 */

define('CLI_SCRIPT', true);

require('/bitnami/moodle/config.php');
// https://github.com/moodle/moodle/blob/MOODLE_38_STABLE/lib/clilib.php
require_once($CFG->libdir . '/clilib.php');
// core APIs, needed for `set_config`
require_once($CFG->libdir . '/moodlelib.php');

$plugindir = dirname(__FILE__) . DIRECTORY_SEPARATOR . 'plugins';
$pluginfiles = array_diff(scandir($plugindir), array('..', '.', 'skip.json'));

// decode JSON as associative array
// plugins skip.json is nested arrays like
// { "plugin_name": ["skip this", "and this"], "second_plugin": ["this too"] }
$skip = json_decode(file_get_contents($plugindir . DIRECTORY_SEPARATOR . 'skip.json'), true);

cli_write(date('Y-m-d H:i:s', time()));
cli_writeln(" Synchronizing settings for plugins...\n");

foreach ($pluginfiles as $pluginfile) {
    $plugin_config = json_decode(file_get_contents($plugindir . DIRECTORY_SEPARATOR . $pluginfile), true);
    $plugin_name = explode(".json", $pluginfile)[0];

    cli_heading("$plugin_name settings");

    foreach ($plugin_config as $key => $value) {
        if (isset($skip[$plugin_name]) && in_array($key, $skip[$plugin_name])) {
            cli_writeln("Skipping \"$key\" because it is in the skip.json file.");
        } else if ($key == 'version') {
            cli_writeln("Skipping plugin version.");
        } else {
            cli_writeln("Setting \"$key\" to \"$value\"");
            set_config($key, $value);
        }
    }

    // space between each plugin's section
    cli_writeln("");
}

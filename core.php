<?php

// Synchronize configuration settings from a given JSON file.

/**
 *
 * @package    core
 * @subpackage cli
 * @copyright  2020 CCA (https://cca.edu)
 * @license    https://opensource.org/licenses/ECL-2.0 ECL 2.0
 */

define('CLI_SCRIPT', true);

require('/opt/moodle38/config.php');
// https://github.com/moodle/moodle/blob/MOODLE_38_STABLE/lib/clilib.php
require_once($CFG->libdir . '/clilib.php');
// core APIs, needed for `set_config`
require_once($CFG->libdir . '/moodlelib.php');

// decode JSON as associative array
$config = json_decode(file_get_contents('config.json'), true);
$skip = json_decode(file_get_contents('skip.json'), true);

cli_write(date('Y-m-d H:i:s', time()));
cli_writeln(" Synchronizing settings for Moodle core...\n");

foreach ($config as $key => $value) {
    if (in_array($key, $skip)) {
            cli_writeln("Skipping \"$key\" because it is in the skip.json file.");
    } else {
        cli_writeln("Setting \"$key\" to \"$value\"");
        set_config($key, $value);
    }
}

# An exec to remove the default backupset if it doesn't exist.
#
# The `holland` package installs a default file with a `default` backup set
# configured but doesn't lay down a configuration file for this backup set
# which causes the `holland backup` command to fail.  This `exec` removes the
# backup set if there isn't a backup set configuration file in place for it.
# All backup set defines should notify this the config class.
#
# @summary An exec to remove the default backupset if it doesn't exist.
#
# @api private
#
# @example
#   include holland::config::remove_default
class holland::config::remove_default {

  exec { 'holland_remove_default_set':
    command     => '/bin/sed -i -e \'s/\(^[[:space:]]*backupsets.*\),[[:space:]]*default[[:space:]]*$/\1/g\' -e \'s/\(^[[:space:]]*backupsets.*\)default[, ]*\(.*\)/\1\2/g\' /etc/holland/holland.conf', # lint:ignore:140chars
    onlyif      => '/bin/grep -q \'backupsets.*default\' /etc/holland/holland.conf',
    unless      => '/usr/bin/test -f /etc/holland/backupsets/default.conf',
    refreshonly => true,
    require     => Package['holland'],
  }
}

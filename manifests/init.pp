# Common setup and resources for the [Holland Backup Manager](http://hollandbackup.org/).
# There isn't an [Augeas](http://augeas.net/) lens for `holland.conf` in the
# upstream project yet so we'll need to provide one ourselves to manage the
# main configuration from more than one class. Since Puppet requires
# `augeas-libs` we don't need to manage the parrent directories since they'll
# already be in place.
#
# @summary Common setup and resources for the Holland Backup Manager
#
# @param ensure
#   Should Holland be installed or not.
#
# @param backup_directory
#   Top-level directory where backups are held.
#
# @param logfile
#   The file Holland logs to
#
# @param log_level
#   Sets the verbosity of Holland’s logging process.
#
# @param path
#   Defines a path for holland and its spawned processes
#
# @param plugin_dirs
#   Defines where the plugins can be found. This can be a comma-separated list
#   but usually does not need to be modified.
#
# @param umask
#   Sets the umask of the resulting backup files.
#
# @example Basic
#   include holland
class holland (
  Enum['absent', 'present'] $ensure           = present,
  String                    $backup_directory = '/var/spool/holland',
  String                    $logfile          = '/var/log/holland/holland.log',
  Enum[
    'debug',
    'info',
    'warning',
    'error',
    'critical'
  ]                         $log_level        = 'info',
  String                    $path             = '/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin',
  String                    $plugin_dirs      = '/usr/share/holland/plugins',
  String                    $umask            = '0007',
){

  contain ::holland::install

  if $ensure == 'present' {
    contain ::holland::config
    Class['holland::install'] -> Class['holland::config']
  }
  # The `holland` package installs a default file with a `default` backup set
  # configured but doesn't lay down a configuration file for this backup set
  # which causes the `holland backup` command to fail.  This `exec` removes the
  # backup set if there isn't a backup set configuration file in place for it.
  # All backup set defines should notify this `exec`.
  exec { 'holland_remove_default_set':
    command     => '/bin/sed -i -e \'s/\(^[[:space:]]*backupsets.*\),[[:space:]]*default[[:space:]]*$/\1/g\' -e \'s/\(^[[:space:]]*backupsets.*\)default[, ]*\(.*\)/\1\2/g\' /etc/holland/holland.conf', # lint:ignore:140chars
    onlyif      => '/bin/grep -q \'backupsets.*default\' /etc/holland/holland.conf',
    unless      => '/usr/bin/test -f /etc/holland/backupsets/default.conf',
    refreshonly => true,
    require     => Package['holland'],
  }
}

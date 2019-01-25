# @summary Manage the overall [Holland Backup Manager](http://hollandbackup.org/)
#    configuration.
#
# @api private
#
# @example
#   include holland::config
class holland::config (
  String $backup_directory = $::holland::backup_directory,
  String $logfile          = $::holland::logfile,
  String $log_level        = $::holland::log_level,
  String $path             = $::holland::path,
  String $plugin_dirs      = $::holland::plugin_dirs,
  String $umask            = $::holland::umask,
) {
  validate_absolute_path($backup_directory)
  validate_absolute_path($logfile)

  $basic_changes       = [
    "set holland/backup_directory ${backup_directory}",
    "set holland/path ${path}",
    "set holland/umask ${umask}",
    "set logging/filename ${logfile}",
    "set logging/level ${log_level}",]

  # TODO test all plugin_dirs entries are valid file paths
  $plugin_dirs_changes = regsubst($plugin_dirs, '(.*)', 'set holland/plugin_dirs/path[ . = "\1" ] \1')

  # FIXME Work around a bug in Puppet 2.6 that doesn't handle parsing arrays as
  # the only argument to a function.
  $conf_changes        = [ $basic_changes, $plugin_dirs_changes ]
  $augeas_changes      = flatten($conf_changes)

  # The file `holland.aug` is managed by the `holland::install` class
  augeas { '/etc/holland/holland.conf':
    context => '/files/etc/holland/holland.conf/',
    incl    => '/etc/holland/holland.conf',
    lens    => 'Holland.lns',
    changes => $augeas_changes,
    onlyif  => 'match holland size == 1',
    require => Class['holland::install'],
  }

  # The `holland` package installs a default file with a `default` backup set
  # configured but doesn't lay down a configuration file for this backup set
  # which causes the `holland backup` command to fail.  This `exec` removes the
  # backup set if there isn't a backup set configuration file in place for it.
  # All backup set defines should notify this the config class.
  exec { 'holland_remove_default_set':
    command     => '/bin/sed -i -e \'s/\(^[[:space:]]*backupsets.*\),[[:space:]]*default[[:space:]]*$/\1/g\' -e \'s/\(^[[:space:]]*backupsets.*\)default[, ]*\(.*\)/\1\2/g\' /etc/holland/holland.conf', # lint:ignore:140chars
    onlyif      => '/bin/grep -q \'backupsets.*default\' /etc/holland/holland.conf',
    unless      => '/usr/bin/test -f /etc/holland/backupsets/default.conf',
    refreshonly => true,
    require     => Package['holland'],
  }

}

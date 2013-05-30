# == Class: holland::config
#
# Manage the overall {Holland Backup Manager}[http://hollandbackup.org/] configuration. This only needs to be used if you wish to
# change the default values provided when the +holland+ package is installed.
#
# === Parameters
#
# [*backup_directory*]
#   Top-level directory where backups are held.
# [*logfile*]
#   The file Holland logs to
# [*log_level*]
#   Sets the verbosity of Holland’s logging process. Available options are <tt>debug</tt>, <tt>info</tt>, <tt>warning</tt>,
#   <tt>error</tt>, and <tt>critical</tt>
# [*path*]
#   Defines a path for holland and its spawned processes
# [*plugin_dirs*]
#   Defines where the plugins can be found. This can be a comma-separated list but usually does not need to be modified.
# [*umask*]
#   Sets the umask of the resulting backup files.
#
# === Examples
#
#  class { '::holland::config':
#    example => [ 'server1.example.org', 'server2.example.com' ]
#  }
#
# === Copyright
#
# Copyright 2012 Russell Harrison
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class holland::config (
  $backup_directory = '/var/spool/holland',
  $logfile          = '/var/log/holland/holland.log',
  $log_level        = 'info',
  $path             = '/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin',
  $plugin_dirs      = '/usr/share/holland/plugins',
  $umask            = '0007'
) {
  include ::holland

  validate_absolute_path($backup_directory)
  validate_absolute_path($logfile)

  if !($log_level in ['debug', 'info', 'warning', 'error', 'critical']) {
    fail("log_level = ${log_level} must be one of debug, info, warning, error, or critical")
  }
  $basic_changes       = [
    "set holland/backup_directory ${backup_directory}",
    "set holland/path ${path}",
    "set holland/umask ${umask}",
    "set logging/filename ${logfile}",
    "set logging/level ${log_level}",]

  # TODO test all plugin_dirs entries are valid file paths
  $plugin_dirs_changes = regsubst($plugin_dirs, '(.*)', 'set holland/plugin_dirs/path[ . = "\1" ] \1')

  # FIXME Work around a bug in Puppet 2.6 that doesn't handle parsing arrays as the only argument to a function.
  $conf_changes        = [ $basic_changes, $plugin_dirs_changes ]
  $augeas_changes      = flatten($conf_changes)

  # The file +holland.aug+ is managed by the +holland+ class
  augeas { '/etc/holland/holland.conf':
    context => '/files/etc/holland/holland.conf/',
    incl    => '/etc/holland/holland.conf',
    lens    => 'Holland.lns',
    changes => $augeas_changes,
    onlyif  => 'match holland size == 1',
    require => [
      File['/usr/share/augeas/lenses/dist/holland.aug'],
      Package['holland'],
    ],
  }

}

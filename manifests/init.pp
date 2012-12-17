# == Class: holland
#
# Common setup for the {Holland Backup Manager}[http://hollandbackup.org/]. For most users these settings will not need to be
# changed.
#
# === Parameters
#
# [*backup_directory*]
#   Top-level directory where backups are held.
# [*logfile*]
#   The file Holland logs to
# [*loglevel*]
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
#  class { 'holland':
#    loglevel => 'debug',
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
class holland (
  $backup_directory = '/var/spool/holland',
  $logfile          = '/var/log/holland/holland.log',
  $loglevel         = 'info',
  $path             = '/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin',
  $plugin_dirs      = '/usr/share/holland/plugins',
  $umask            = '0007'
) {
  include holland::augeas

  # The base Holland package
  package { 'holland':
    ensure => present,
  }

  validate_absolute_path($backup_directory)
  validate_absolute_path($logfile)

  if !($loglevel in ['debug', 'info', 'warning', 'error', 'critical']) {
    fail("loglevel = ${loglevel} must be one of debug, info, warning, error, or critical")
  }
  $basic_changes       = [
    "set holland/backup_directory ${backup_directory}",
    "set holland/path ${path}",
    "set holland/umask ${umask}",
    "set logging/filename ${logfile}",
    "set logging/level ${loglevel}",]

  # TODO test all plugin_dirs entries are valid file paths
  $plugin_dirs_changes = regsubst($plugin_dirs, '(.*)', 'set holland/plugin_dirs[ . = "\1" ] \1')

  $conf_changes        = flatten([$basic_changes, $plugin_dirs_changes])

  # The file +holland.aug+ is managed by the +holland::augeas+ class
  augeas { '/etc/holland/holland.conf':
    context => '/files/etc/holland/holland.conf',
    changes => $conf_changes,
    require => [
      File['/usr/share/augeas/lenses/dist/holland.aug'],
      Package['holland'],
    ],
  }
}

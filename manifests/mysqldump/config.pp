# == Class: holland::mysqldump::config
#
# Change the global configuration for the {Holland Backup Manager}[http://hollandbackup.org/]
# {mysqldump}[http://docs.hollandbackup.org/provider_configs/mysqldump.html] provider.  These settings
# can be overridden by the configuration values provided in a specific +mysqldump+ backup set.
#
# === Parameters
#
# [*ensure*]
#   Wheither to ensure the configuration is a <tt>file</tt> or <tt>absent</tt>.
# [*additional_options*]
#   Optionally specify additional options directly to <tt>mysqldump</tt> if there is no native Holland option for it. These should
#   show up exactly as they are on the command line. e.g.: <tt>--flush-privileges --reset-master</tt>
# [*bin_log_position*]
#   Record the binary log name and position at the time of the backup. <tt>'yes'</tt> or <tt>'no'</tt>. *Note* that if both
#   <tt>‘stop-slave’</tt> and <tt>‘bin-log-position’</tt> are enabled, Holland will grab the master binary log name and position at
#   the time of the backup which can be useful in using the backup to create slaves or for point in time recovery using the master’s
#   binary log. This information is found within the <tt>‘backup.conf’</tt> file located in the backup-set destination directory
#   (<tt>/var/spool/holland/<backup-set>/<backup></tt> by default). For example:
#
#      [mysql:replication]
#      slave_master_log_pos = 4512
#      slave_master_log_file = 260792-mmm-agent1-bin-log.000001
# [*compress_bin_path*]
#   This only needs to be defined if the compression utility is in a non-standard location, or not in the system path.
# [*compress_inline*]
#   Whether or not to pipe the output of <tt>mysqldump</tt> into the compression utility. <tt>'yes'</tt> or <tt>'no'</tt>. Enabling
#   this is recommended since it usually only marginally impacts performance, particularly when using a lower compression level.
# [*compress_level*]
#   Specify the compression ratio from <tt>0</tt> to <tt>9</tt>. The lower the number, the lower the compression ratio, but the
#   faster the backup will take. Generally, setting the lever to 1 or 2 results in favorable compression of textual data and is
#   noticeably faster than the higher levels. Setting the level to 0 effectively disables compression.
# [*compress_method*]
#   Define which compression method to use. One of <tt>'gzip'</tt>, <tt>'pigz'</tt>, <tt>'bzip'</tt>, <tt>'lzop'</tt>, or
#   </tt>'lzma'</tt>. Note that <tt>lzop</tt> and <tt>lzma</tt> may not be available on every system and may need to be compiled /
#   installed.
# [*databases*]
#   Comma-delimited glob patterns for matching databases. Only databases matching these patterns will be backed up. The default is
#   <tt>'*'</tt> which includes everything.
# [*defaults_extra_file*]
#   Comma seperated list of locations to look for the MySQL conection information using the standard <tt>.my.cnf</tt> conventions.
#   Defaults to <tt>'/root/.my.cnf,~/.my.cnf,'</tt>.
# [*dump_events*]
#   Whether or not to dump events explicitly. <tt>'yes'</tt> or <tt>'no'</tt>. Like routines, events are stored in the ‘mysql’
#   database. Nonetheless, it can sometimes be convenient to include them in the backup-set directly. *Note*: This feature requires
#   MySQL 5.1 or later.
# [*dump_routines*]
#   Whether or not to backup routines in the backup set directly. Routines are stored in the ‘mysql’ database, but it can sometimes
#   be convenient to include them in a backup-set directly. <tt>'yes'</tt> or <tt>'no'</tt>.
# [*exclude_databases*]
#   Comma-delimited glob patterns to exclude particular databases.
# [*exclude_tables*]
#   Comma-delimited glob patterns to exclude particular tables.
# [*file_per_database*]
#   Whether or not to split up each database into its own file. <tt>'yes'</tt> or <tt>'no'</tt>. Note that it can be more consistent
#   and efficient to backup all databases into one file, however this means that restore a single database can be difficult if
#   multiple databases are defined in the backup set.
# [*flush_logs*]
#   Whether or not to run <tt>FLUSH LOGS</tt> in MySQL with the backup. <tt>'yes'</tt> or <tt>'no'</tt>. When <tt>FLUSH LOGS</tt> is
#   actually executed depends on which if database filtering is being used and whether or not <tt>file-per-database</tt> is enabled.
#   Generally speaking, it does not make sense to use <tt>flush-logs</tt> with <tt>file-per-database</tt> since the binary logs will
#   not be consistent with the backup.
# [*lock_method*]
#   One of: <tt>flush-lock</tt>, <tt>lock-tables</tt>, <tt>single-transaction</tt>, <tt>auto-detect</tt>, <tt>none</tt>
#
#   <tt>flush-lock</tt> will place a global lock on all tables involved in the backup regardless of whether or not they are in the
#   backup-set. If <tt>file-per-database</tt> is enabled, then <tt>flush-lock</tt> will lock all tables for every database being
#   backed up. In other words, this option may not make much sense when using <tt>file-per-database</tt>.
#
#   <tt>lock-tables</tt> will lock all tables involved in the backup. If <tt>file-per-database</tt> is enabled, then
#   <tt>lock-tables</tt> will only lock all the tables associated with that database.
#
#   <tt>single-transaction</tt> will force running a backup within a transaction. This allows backing up of transactional tables
#   without imposing a lock howerver will NOT properly backup non-transacitonal tables.
#
#   <tt>auto-detect</tt> will choose single-transaction unless Holland finds non-transactional tables in the backup-set.
#
#   <tt>none</tt> will completely disable locking. This is generally only viable on a MySQL slave and only after traffic has been
#   diverted, or slave services suspended.
# [*mysql_binpath*]
#   Defines the location of the MySQL binary utilities. If not provided, Holland will use whatever is in the path.
# [*mysql_host*]
#   The FQDN of the remote host to connect to MySQL on.
# [*mysql_password*]
#   The password for the MySQL user.
# [*mysql_port*]
#   Used if MySQL is running on a port other than <tt>3306</tt>.
# [*mysql_socket*]
#   The socket file to connect to MySQL with. eg. <tt>'/tmp/mysqld.sock'</tt>.
# [*mysql_user*]
#   The user to connect to MySQL as.
# [*stop_slave*]
#   This is useful only when running Holland on a MySQL slave. Instructs Holland to suspend slave services on the server prior to
#   running the backup. Suspending the slave does not change the backups, but does prevent the slave from spooling up relay logs.
#   The default is not to suspend the slave (if applicable). <tt>'yes'</tt> or <tt>'no'</tt>.
# [*tables*]
#   Only include the specified tables. Comma seperated glob patterns.
#
# === Examples
#
#  class { 'holland::mysqldump::config':
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
class holland::mysqldump::config (
  $ensure              = 'file',
  $additional_options  = '',
  $bin_log_position    = 'no',
  $compress_bin_path   = undef,
  $compress_inline     = 'yes',
  $compress_level      = 1,
  $compress_method     = 'gzip',
  $databases           = undef,
  $defaults_extra_file = '/root/.my.cnf,~/.my.cnf,',
  $dump_events         = 'no',
  $dump_routines       = 'no',
  $exclude_databases   = undef,
  $exclude_tables      = undef,
  $file_per_database   = 'no',
  $flush_logs          = 'no',
  $lock_method         = 'auto-detect',
  $mysql_binpath       = undef,
  $mysql_host          = undef,
  $mysql_password      = undef,
  $mysql_port          = undef,
  $mysql_socket        = undef,
  $mysql_user          = undef,
  $stop_slave          = 'no',
  $tables              = undef
) {
  include holland::mysqldump

  if !($ensure in [
    'file',
    'absent']) {
    fail("ensure = ${ensure} must be either 'file' or 'absent'")
  }
  validate_string($additional_options)

  if !($bin_log_position in ['yes', 'no']) {
    fail("bin_log_position = ${bin_log_position} must be either 'yes' or 'no'")
  }

  if $compress_bin_path {
    validate_absolute_path($compress_bin_path)
  }

  if !($compress_inline in ['yes', 'no']) {
    fail("compress_inline = ${compress_inline} must be either 'yes' or 'no'")
  }

  if !( is_integer($compress_level) ) and !( member( range(0, 9), $compress_level ) ) {
    fail("compress_level = ${compress_level} must be an integer in the range 0 to 9")
  }

  if !($compress_method in ['gzip', 'pigz', 'bzip', 'lzop', 'lzma']) {
    fail("compress_method = ${compress_method} must be one of 'gzip', 'pigz', 'bzip', 'lzop', or 'lzma'")
  }

  if $databases {
    validate_string($databases)
  }
  validate_string($defaults_extra_file)

  if !($dump_events in ['yes', 'no']) {
    fail("dump_events = ${dump_events} must be either 'yes' or 'no'")
  }

  if !($dump_routines in ['yes', 'no']) {
    fail("dump_routines = ${dump_routines} must be either 'yes' or 'no'")
  }

  if $exclude_databases {
    validate_string($exclude_databases)
  }

  if $exclude_tables {
    validate_string($exclude_tables)
  }

  if !($file_per_database in ['yes', 'no']) {
    fail("file_per_database = ${file_per_database} must be either 'yes' or 'no'")
  }

  if !($flush_logs in ['yes', 'no']) {
    fail("flush_logs = ${flush_logs} must be either 'yes' or 'no'")
  }

  if !($lock_method in ['flush-lock', 'lock-tables', 'single-transaction', 'auto-detect', 'none']) {
    fail("lock_method = ${lock_method} must be one of 'flush-lock', 'lock-tables', 'single-transaction', 'auto-detect', or 'none'")
  }

  if $mysql_binpath {
    validate_absolute_path($mysql_binpath)
  }

  # Validate the +mysql_host+ is a fully qualified domain names
  if $mysql_host {
    validate_re($mysql_host, '^[a-z0-9_-]+(\.[a-z0-9_-]+){2,}$')
  }

  if $mysql_password {
    validate_string($mysql_password)
  }

  if $mysql_port and !is_integer($mysql_port) {
    fail("mysql_port = ${mysql_port} must be a port number")
  }

  if $mysql_socket {
    validate_absolute_path($mysql_socket)
  }

  if $mysql_user {
    validate_string($mysql_user)
  }

  if !($stop_slave in ['yes', 'no']) {
    fail("stop_slave = ${stop_slave} must be either 'yes' or 'no'")
  }

  if $tables {
    validate_string($tables)
  }

  # Configure the global mysqldump provider configuration.
  file { '/etc/holland/providers/mysqldump.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('holland/providers/mysqldump.conf.erb'),
    require => Package['holland-mysqldump'],
  }
}

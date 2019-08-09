# @summary Configures a mysqldump backup set for Holland
#
# @param ensure
#   Wheither to ensure the configuration is installed or not.
#
# @param additional_options
#   Specify additional options directly to the `mysqldump` command if there is
#   no native Holland option for it. These should show up exactly as they would
#   on the command line. e.g.: `'--flush-privileges --reset-master'`
#
# @param after_backup_command
#   Command to run after successful backup.
#
# @param auto_purge_failures
#   Specifies whether to keep a failed backup or to automatically remove the
#   backup directory. By default this is on with the intention that whatever
#   process is calling holland will retry when a backup fails. This behavior
#   can be disabled by setting `auto-purge-failures = no` when partial backups
#   might be useful or when troubleshooting a backup failure.
#
# @param backups_to_keep
#   Specifies the number of backups to keep for a backup-set.
#
# @param before_backup_command
#   Run a shell command before a backup starts.
#
# @param compress_bin_path
#   This only needs to be defined if the compression utility is in a
#   non-standard location, or not in the system path.
#
# @param compress_inline
#   Whether or not to pipe the output of `mysqldump` into the compression
#   utility. Enabling this is recommended since it usually only marginally
#   impacts performance, particularly when using a lower compression level.
#
# @param compress_level
#   Specify the compression ratio from `0` to `9`. The lower the number, the
#   lower the compression ratio, but the faster the backup will take. Generally,
#   setting the lever to `1` or `2` results in favorable compression of textual
#   data and is noticeably faster than the higher levels. Setting the level to
#   `0` effectively disables compression.
#
# @param compress_method
#   Define which compression method to use.  Note that `lzop` and `lzma` may
#   not be available on every system and may need to be compiled / installed.
#
# @param databases
#   Comma-delimited glob patterns for matching databases. Only databases
#   matching these patterns will be backed up. The default is`'*'` which
#   includes everything.
#
# @param defaults_extra_file
#   Comma seperated list of locations to look for the MySQL conection
#   information using the standard `.my.cnf` conventions.
#
# @param dump_events
#   Whether or not to dump events explicitly.  Like routines, events are stored
#   in the 'mysql' database. Nonetheless, it can sometimes be convenient to
#   include them in the backup-set directly. **Note**: This feature requires
#   MySQL 5.1 or later.
#
# @param dump_routines
#   Whether or not to backup routines in the backup set directly. Routines are
#   stored in the 'mysql' database, but it can sometimes be convenient to
#   include them in a backup-set directly.
#
# @param estimated_size_factor
#   Specifies the scale factor when Holland decides if there is enough free
#   space to perform a backup. This number is multiplied against what each
#   individual plugin reports its estimated backup size when Holland is
#   verifying sufficient free space for the backupset.
#
# @param exclude_databases
#   Comma-delimited glob patterns to exclude particular databases.
#
# @param exclude_tables
#   Comma-delimited glob patterns to exclude particular tables.
#
# @param failed_backup_command
#   Command to run after failed backup.
#
# @param file_per_database
#   Whether or not to split up each database into its own file.  Note that it
#   can be more consistent and efficient to backup all databases into one file,
#   however this means that restore a single database can be difficult if
#   multiple databases are defined in the backup set.
#
# @param flush_logs
#   Whether or not to run `FLUSH LOGS` in MySQL with the backup.  When
#   `FLUSH LOGS` is actually executed depends on which if database filtering is
#   being used and whether or not `file-per-database` is enabled.  Generally
#   speaking, it does not make sense to use `flush-logs` with
#   `file-per-database` since the binary logs will not be consistent with the
#   backup.
#
# @param lock_method
#   `flush-lock` will place a global lock on all tables involved in the backup
#   regardless of whether or not they are in the backup-set. If
#   `file-per-database` is enabled, then `flush-lock` will lock all tables for
#   every database being backed up. In other words, this option may not make
#   much sense when using `file-per-database`.
#
#   `lock-tables` will lock all tables involved in the backup. If
#   `file-per-database` is enabled, then `lock-tables` will only lock all the
#   tables associated with that database.
#
#   `single-transaction` will force running a backup within a transaction.  This
#   allows backing up of transactional tables without imposing a lock however
#   will NOT properly backup non-transacitonal tables.
#
#   `auto-detect` will choose single-transaction unless Holland finds
#   non-transactional tables in the backup-set.
#
#   `none` will completely disable locking. This is generally only viable on a
#   MySQL slave and only after traffic has been diverted, or slave services
#   suspended.
#
# @param mysql_binpath
#   Defines the location of the MySQL binary utilities. If not provided,
#   Holland will use whatever is in the path.
#
# @param mysql_host
#   The FQDN of the remote host to connect to MySQL on.
#
# @param mysql_password
#   The password for the MySQL user.
#
# @param mysql_port
#   Used if MySQL is running on a port other than `3306`.
#
# @param mysql_socket
#   The socket file to connect to MySQL with. eg. `'/tmp/mysqld.sock'`.
#
# @param mysql_user
#   The user to connect to MySQL as.
#
# @param purge_policy
#   Specifies when to run the purge routine on a backupset. By default this is
#   run after a new successful backup completes. Up to `backups_to_keep` backups
#   will be retained including the most recent.
#
#   `before-backup` will run the purge routine just before a new backup starts.
#   This will retain up to `backups_to_keep` backups before the new backup is
#   even started allowing purging all previous backups if `backups_to_keep` is
#   set to `0`. This behavior is useful if some other process is retaining
#   backups off-server and disk space is at a premium.
#
#   `manual` will never run the purge routine automatically. Either
#   `holland purge` must be run externally or an explicit removal of desired
#   backup directories can be done at some later time.
#
# @param stop_slave
#   This is useful only when running Holland on a MySQL slave. Instructs
#   Holland to suspend slave services on the server prior to running the backup.
#   Suspending the slave does not change the backups, but does prevent the
#   slave from spooling up relay logs.  The default is not to suspend the slave
#   (if applicable).
#
# @param tables
#   Only include the specified tables. Comma seperated glob patterns.
#
# @example Basic
#   holland::mysqldump::backupset { 'namevar': }
define holland::mysqldump::backupset(
  Enum['absent', 'file']                          $ensure                = file,
  Optional[String]                                $additional_options    = undef,
  Optional[String]                                $after_backup_command  = undef,
  Enum['no', 'yes']                               $auto_purge_failures   = 'yes',
  Integer                                         $backups_to_keep       = 1,
  Optional[String]                                $before_backup_command = undef,
  Optional[String]                                $compress_bin_path     = undef,
  Enum['no', 'yes']                               $compress_inline       = 'yes',
  Integer[0, 9]                                   $compress_level        = 1,
  Enum['gzip', 'pigz', 'bzip', 'lzop', 'lzma']    $compress_method       = 'gzip',
  Optional[String]                                $databases             = undef,
  Optional[String]                                $defaults_extra_file   = undef,
  Optional[Enum['no', 'yes']]                     $dump_events           = undef,
  Optional[Enum['no', 'yes']]                     $dump_routines         = undef,
  Float                                           $estimated_size_factor = 1.0,
  Optional[String]                                $exclude_databases     = undef,
  Optional[String]                                $exclude_tables        = undef,
  Optional[String]                                $failed_backup_command = undef,
  Optional[Enum['no', 'yes']]                     $file_per_database     = undef,
  Optional[Enum['no', 'yes']]                     $flush_logs            = undef,
  Enum[
    'flush-lock',
    'lock-tables',
    'single-transaction',
    'auto-detect',
    'none'
  ]                                               $lock_method           = 'auto-detect',
  Optional[String]                                $mysql_binpath         = undef,
  Optional[String]                                $mysql_host            = undef,
  Optional[String]                                $mysql_password        = undef,
  Optional[Integer]                               $mysql_port            = undef,
  Optional[String]                                $mysql_socket          = undef,
  Optional[String]                                $mysql_user            = undef,
  Enum['manual', 'before-backup', 'after-backup'] $purge_policy          = 'after-backup',
  Optional[Enum['no', 'yes']]                     $stop_slave            = undef,
  Optional[String]                                $tables                = undef,
) {

  if $compress_bin_path {
    validate_absolute_path($compress_bin_path)
  }

  if $mysql_binpath {
    validate_absolute_path($mysql_binpath)
  }

  if $mysql_socket {
    validate_absolute_path($mysql_socket)
  }

  $file_ensure = $ensure ? {
    'present' => file,
    default   => $ensure
  }

  file { "/etc/holland/backupsets/${name}.conf":
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('holland/backupsets/mysqldump.conf.erb'),
    require => Class['holland::mysqldump'],
  }

  $augeas_changes = $ensure ? {
    'absent' => "rm holland/backupsets/set[ . = \"${name}\"]",
    default  => "set holland/backupsets/set[ . = \"${name}\"] ${name}",
  }

  # Add the backup set to the main <tt>holland.conf</tt>
  augeas { "/etc/holland/holland.conf/holland/backupsets/set ${name}":
    context => '/files/etc/holland/holland.conf/',
    incl    => '/etc/holland/holland.conf',
    lens    => 'Holland.lns',
    changes => $augeas_changes,
    onlyif  => 'match holland size == 1',
    require => File["/etc/holland/backupsets/${name}.conf"],
    notify  => Class['holland::config::remove_default'],
  }
}

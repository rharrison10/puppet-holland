# This class manages the [Holland Backup Manager](http://hollandbackup.org/)
# `mysqldump` provider.
#
# @summary Manage the Holland mysqldump provider
#
# @param ensure
#   Should the mysqldump provider be installed or not.
#
# @param additional_options
#   Specify additional options directly to the `mysqldump` command if there is
#   no native Holland option for it. These should show up exactly as they would
#   on the command line. e.g.: `'--flush-privileges --reset-master'`
#
# @param bin_log_position
#   Record the binary log name and position at the time of the backup. **Note**
#   that if both `'stop-slave'` and `'bin-log-position'` are enabled, Holland
#   will grab the master binary log name and position at the time of the backup
#   which can be useful in using the backup to create slaves or for point in
#   time recovery using the master’s binary log. This information is found
#   within the `'backup.conf'` file located in the backup-set destination
#   directory (`/var/spool/holland/<backup-set>/<backup>` by default).
#
#   For example:
#
#       [mysql:replication]
#       slave_master_log_pos = 4512
#       slave_master_log_file = 260792-mmm-agent1-bin-log.000001
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
# @param exclude_databases
#   Comma-delimited glob patterns to exclude particular databases.
#
# @param exclude_tables
#   Comma-delimited glob patterns to exclude particular tables.
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
#   include holland::mysqldump
class holland::mysqldump (
  Enum['absent', 'present']                    $ensure              = present,
  String                                       $additional_options  = '',
  Enum['no', 'yes']                            $bin_log_position    = 'no',
  Optional[String]                             $compress_bin_path   = undef,
  Enum['no', 'yes']                            $compress_inline     = 'yes',
  Integer[0, 9]                                $compress_level      = 1,
  Enum['gzip', 'pigz', 'bzip', 'lzop', 'lzma'] $compress_method     = 'gzip',
  Optional[String]                             $databases           = undef,
  String                                       $defaults_extra_file = '/root/.my.cnf,~/.my.cnf,',
  Enum['no', 'yes']                            $dump_events         = 'no',
  Enum['no', 'yes']                            $dump_routines       = 'no',
  Optional[String]                             $exclude_databases   = undef,
  Optional[String]                             $exclude_tables      = undef,
  Enum['no', 'yes']                            $file_per_database   = 'no',
  Enum['no', 'yes']                            $flush_logs          = 'no',
  Enum[
    'flush-lock',
    'lock-tables',
    'single-transaction',
    'auto-detect',
    'none'
  ]                                            $lock_method         = 'auto-detect',
  Optional[String]                             $mysql_binpath       = undef,
  Optional[String]                             $mysql_host          = undef,
  Optional[String]                             $mysql_password      = undef,
  Optional[Integer]                            $mysql_port          = undef,
  Optional[String]                             $mysql_socket        = undef,
  Optional[String]                             $mysql_user          = undef,
  Enum['no', 'yes']                            $stop_slave          = 'no',
  Optional[String]                             $tables              = undef,
){
  contain ::holland::mysqldump::install
  contain ::holland::mysqldump::config

  if ensure == 'present' {
    Class['holland::mysqldump::install'] -> Class['holland::mysqldump::config']
  } else {
    Class['holland::mysqldump::config'] -> Class['holland::mysqldump::install']
  }
}

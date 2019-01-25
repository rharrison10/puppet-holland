# Change the global configuration for the [Holland Backup Manager](http://hollandbackup.org/)
# [mysqldump](http://docs.hollandbackup.org/provider_configs/mysqldump.html)
# provider.  These settings can be overridden by the configuration values
# provided in a specific `mysqldump` backup set.
#
# @summary Manage the Holland mysqldump provider configuration.
#
# @api private
#
class holland::mysqldump::config (
  Enum['absent', 'present']                    $ensure              = $::holland::mysqldump::ensure,
  String                                       $additional_options  = $::holland::mysqldump::additional_options,
  Enum['no', 'yes']                            $bin_log_position    = $::holland::mysqldump::bin_log_position,
  Optional[String]                             $compress_bin_path   = $::holland::mysqldump::compress_bin_path,
  Enum['no', 'yes']                            $compress_inline     = $::holland::mysqldump::compress_inline,
  Integer[0, 9]                                $compress_level      = $::holland::mysqldump::compress_level,
  Enum['gzip', 'pigz', 'bzip', 'lzop', 'lzma'] $compress_method     = $::holland::mysqldump::compress_method,
  Optional[String]                             $databases           = $::holland::mysqldump::databases,
  String                                       $defaults_extra_file = $::holland::mysqldump::defaults_extra_file,
  Enum['no', 'yes']                            $dump_events         = $::holland::mysqldump::dump_events,
  Enum['no', 'yes']                            $dump_routines       = $::holland::mysqldump::dump_routines,
  Optional[String]                             $exclude_databases   = $::holland::mysqldump::exclude_databases,
  Optional[String]                             $exclude_tables      = $::holland::mysqldump::exclude_tables,
  Enum['no', 'yes']                            $file_per_database   = $::holland::mysqldump::file_per_database,
  Enum['no', 'yes']                            $flush_logs          = $::holland::mysqldump::flush_logs,
  Enum[
    'flush-lock',
    'lock-tables',
    'single-transaction',
    'auto-detect',
    'none'
  ]                                            $lock_method         = $::holland::mysqldump::lock_method,
  Optional[String]                             $mysql_binpath       = $::holland::mysqldump::mysql_binpath,
  Optional[String]                             $mysql_host          = $::holland::mysqldump::mysql_host,
  Optional[String]                             $mysql_password      = $::holland::mysqldump::mysql_password,
  Optional[Integer]                            $mysql_port          = $::holland::mysqldump::mysql_port,
  Optional[String]                             $mysql_socket        = $::holland::mysqldump::mysql_socket,
  Optional[String]                             $mysql_user          = $::holland::mysqldump::mysql_user,
  Enum['no', 'yes']                            $stop_slave          = $::holland::mysqldump::stop_slave,
  Optional[String]                             $tables              = $::holland::mysqldump::tables,
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
    default   => $ensure,
  }

  # Configure the global mysqldump provider configuration.
  file { '/etc/holland/providers/mysqldump.conf':
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('holland/providers/mysqldump.conf.erb'),
  }
}

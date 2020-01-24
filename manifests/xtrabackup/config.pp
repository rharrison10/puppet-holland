# @summary Manage the Holland xtrabackup provider configuration.
#
# @api private
#
class holland::xtrabackup::config (
  Enum['absent', 'present']                    $ensure                = $::holland::xtrabackup::ensure,
  Optional[String]                             $additional_options    = $::holland::xtrabackup::additional_options,
  Enum['no', 'yes']                            $apply_logs            = $::holland::xtrabackup::apply_logs,
  Optional[String]                             $after_backup_command  = $::holland::xtrabackup::after_backup_command,
  Optional[String]                             $before_backup_command = $::holland::xtrabackup::before_backup_command,
  Optional[String]                             $compress_bin_path     = $::holland::xtrabackup::compress_bin_path,
  Enum['no', 'yes']                            $compress_inline       = $::holland::xtrabackup::compress_inline,
  Integer[0, 9]                                $compress_level        = $::holland::xtrabackup::compress_level,
  Enum['gzip', 'pigz', 'bzip', 'lzop', 'lzma'] $compress_method       = $::holland::xtrabackup::compress_method,
  Optional[String]                             $compress_options      = $::holland::xtrabackup::compress_options,
  Enum['no', 'yes']                            $compress_split        = $::holland::xtrabackup::compress_split,
  String                                       $defaults_extra_file   = $::holland::xtrabackup::defaults_extra_file,
  Optional[String]                             $failed_backup_command = $::holland::xtrabackup::failed_backup_command,
  Optional[String]                             $mysql_binpath         = $::holland::xtrabackup::mysql_binpath,
  Optional[String]                             $mysql_host            = $::holland::xtrabackup::mysql_host,
  Optional[String]                             $mysql_password        = $::holland::xtrabackup::mysql_password,
  Optional[Integer]                            $mysql_port            = $::holland::xtrabackup::mysql_port,
  Optional[String]                             $mysql_socket          = $::holland::xtrabackup::mysql_socket,
  Optional[String]                             $mysql_user            = $::holland::xtrabackup::mysql_user,
  Enum['no', 'yes']                            $no_lock               = $::holland::xtrabackup::no_lock,
  Optional[String]                             $pre_command           = $::holland::xtrabackup::pre_command,
  Enum['no', 'yes']                            $safe_slave_backup     = $::holland::xtrabackup::safe_slave_backup,
  Enum['no', 'yes']                            $slave_info            = $::holland::xtrabackup::slave_info,
  Enum['tar', 'xbstream', 'no', 'yes']         $stream                = $::holland::xtrabackup::stream,
) {

  $file_ensure = $ensure ? {
    'present' => file,
    default   => $ensure,
  }

  # Configure the global xtrabackup provider configuration.
  file { '/etc/holland/providers/xtrabackup.conf':
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('holland/providers/xtrabackup.conf.erb'),
  }
}

# This class manages the [Holland Backup Manager](http://hollandbackup.org/)
# `xtrabackup` provider.
#
# @summary Manage the Holland xtrabackup provider
#
# @example Basic
#   include holland::xtrabackup
class holland::xtrabackup (
  Enum['absent', 'present']                    $ensure                = present,
  Optional[String]                             $additional_options    = undef,
  Enum['no', 'yes']                            $apply_logs            = 'yes',
  Optional[String]                             $after_backup_command  = undef,
  Optional[String]                             $before_backup_command = undef,
  Optional[String]                             $compress_bin_path     = undef,
  Enum['no', 'yes']                            $compress_inline       = 'yes',
  Integer[0, 9]                                $compress_level        = 1,
  Enum['gzip', 'pigz', 'bzip', 'lzop', 'lzma'] $compress_method       = 'gzip',
  Optional[String]                             $compress_options      = undef,
  Enum['no', 'yes']                            $compress_split        = 'no',
  String                                       $defaults_extra_file   = '/root/.my.cnf,~/.my.cnf,',
  Optional[String]                             $failed_backup_command = undef,
  Optional[String]                             $mysql_binpath         = undef,
  Optional[String]                             $mysql_host            = undef,
  Optional[String]                             $mysql_password        = undef,
  Optional[Integer]                            $mysql_port            = undef,
  Optional[String]                             $mysql_socket          = undef,
  Optional[String]                             $mysql_user            = undef,
  Enum['no', 'yes']                            $no_lock               = 'no',
  Optional[String]                             $pre_command           = undef,
  Enum['no', 'yes']                            $safe_slave_backup     = 'yes',
  Enum['no', 'yes']                            $slave_info            = 'yes',
  Enum['tar', 'xbstream', 'no', 'yes']         $stream                = 'tar',
){
  contain ::holland::xtrabackup::install
  contain ::holland::xtrabackup::config

  if $ensure == 'present' {
    Class['holland::xtrabackup::install'] -> Class['holland::xtrabackup::config']
  } else {
    Class['holland::xtrabackup::config'] -> Class['holland::xtrabackup::install']
  }
}

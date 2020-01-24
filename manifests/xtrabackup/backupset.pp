# @summary Configures a xtrabackup backup set for Holland
#
# @example Basic
#   holland::xtrabackup::backupset { 'namevar': }
define holland::xtrabackup::backupset(
  Enum['absent', 'file']                          $ensure                = file,
  Optional[String]                                $additional_options    = undef,
  Enum['no', 'yes']                               $apply_logs            = 'yes',
  Enum['no', 'yes']                               $auto_purge_failures   = 'yes',
  Optional[String]                                $after_backup_command  = undef,
  Integer                                         $backups_to_keep       = 1,
  Optional[String]                                $before_backup_command = undef,
  Optional[String]                                $compress_bin_path     = undef,
  Enum['no', 'yes']                               $compress_inline       = 'yes',
  Integer[0, 9]                                   $compress_level        = 1,
  Enum['gzip', 'pigz', 'bzip', 'lzop', 'lzma']    $compress_method       = 'gzip',
  Optional[String]                                $compress_options      = undef,
  Enum['no', 'yes']                               $compress_split        = 'no',
  Optional[String]                                $defaults_extra_file   = undef,
  Float                                           $estimated_size_factor = 1.0,
  Optional[String]                                $failed_backup_command = undef,
  Optional[String]                                $mysql_binpath         = undef,
  Optional[String]                                $mysql_host            = undef,
  Optional[String]                                $mysql_password        = undef,
  Optional[Integer]                               $mysql_port            = undef,
  Optional[String]                                $mysql_socket          = undef,
  Optional[String]                                $mysql_user            = undef,
  Enum['no', 'yes']                               $no_lock               = 'no',
  Optional[String]                                $pre_command           = undef,
  Enum['manual', 'before-backup', 'after-backup'] $purge_policy          = 'after-backup',
  Enum['no', 'yes']                               $safe_slave_backup     = 'yes',
  Enum['no', 'yes']                               $slave_info            = 'yes',
  Enum['tar', 'xbstream', 'no', 'yes']            $stream                = 'tar',
) {
  if ' ' in $name {
    fail('Spaces in name or title are not supported')
  }

  $file_ensure = $ensure ? {
    'present' => file,
    default   => $ensure,
  }

  file { "/etc/holland/backupsets/${name}.conf":
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('holland/backupsets/xtrabackup.conf.erb'),
    #require => Class['holland::xtrabackup'],
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

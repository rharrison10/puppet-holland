# @summary Configuration for the Holland mongodump provider
#
# @api private
#
class holland::mongodump::config (
  Enum['absent', 'present'] $ensure                  = $::holland::mongodump::ensure,
  Optional[String]          $additional_options      = $::holland::mongodump::additional_options,
  Optional[String]          $after_backup_command    = $::holland::mongodump::after_backup_command,
  String                    $authentication_database = $::holland::mongodump::authentication_database,
  Optional[String]          $before_backup_command   = $::holland::mongodump::before_backup_command,
  Integer[0]                $compression_level       = $::holland::mongodump::compression_level,
  Enum[
    'gzip',
    'gzip-rsyncable',
    'bzip2',
    'pbzip2',
    'lzop'
  ]                         $compression_method      = $::holland::mongodump::compression_method,
  Optional[String]          $failed_backup_command   = $::holland::mongodump::failed_backup_command,
  String                    $host                    = $::holland::mongodump::host,
  String                    $password                = $::holland::mongodump::password,
  String                    $username                = $::holland::mongodump::username,
){

  $file_ensure = $ensure ? {
    'present' => 'file',
    default   => $ensure,
  }

  file { '/etc/holland/providers/mongodump.conf':
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('holland/providers/mongodump.conf.erb'),
  }

}

# @summary Configures a mongodump backup set for Holland
#
# @param ensure
#   Should the backup set be installed or not.
#
# @param additional_options
#   Any additional options to the `mongodump` command-line utility these should
#   show up exactly as they are on the command line. e.g.: `'--gzip'`
#
# @param authentication_database
#   The database the mongo user needs to authenticate against.
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
# @param compress_inline
#   Whether or not to pipe the output of `mongodump` into the compression
#   utility. Enabling this is recommended since it usually only marginally
#   impacts performance, particularly when using a lower compression level.
#
# @param compression_level
#   What compression level to use. Lower numbers mean faster compression, though
#   also generally a worse compression ratio. Generally, levels 1-3 are
#   considered fairly fast and still offer good compression for textual data.
#   Levels above 7 can often cause a larger impact on the system due to needing
#   much more CPU resources. Setting the level to 0 effectively disables
#   compresion.
#
# @param compression_method
#   Which compression method to use. Note that lzop is not often installed by
#   default on many Linux distributions and may need to be installed separately.
#
# @param estimated_size_factor
#   Specifies the scale factor when Holland decides if there is enough free
#   space to perform a backup. This number is multiplied against what each
#   individual plugin reports its estimated backup size when Holland is
#   verifying sufficient free space for the backupset.
#
# @param host
#   Hostname for mongodump to connect with.
#
# @param password
#   Password for mongodump to authenticate with.
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
# @param username
#   Username for mongodump to authenticate with.
#
# @example Inherits from provider
#   include ::holland::mongodump
#
#   holland::mongodump::backupset { "localhost":
#     ensure                  => present,
#     authentication_database => 'admin',
#     host                    => 'localhost',
#     password                => 'SomeThingToChange',
#     username                => 'admin',
#   }
define holland::mongodump::backupset(
  Enum['absent', 'present'] $ensure                  = present,
  Optional[String]          $additional_options      = undef,
  Optional[String]          $authentication_database = undef,
  Enum['no', 'yes']         $auto_purge_failures     = 'yes',
  Integer[1]                $backups_to_keep         = 1,
  Enum['no', 'yes']         $compress_inline         = 'yes',
  Integer[0]                $compression_level       = 1,
  Enum[
    'gzip',
    'gzip-rsyncable',
    'bzip2',
    'pbzip2',
    'lzop'
  ]                         $compression_method      = 'gzip',
  Float                     $estimated_size_factor   = 1.0,
  Optional[String]          $host                    = undef,
  Optional[String]          $password                = undef,
  Enum[
    'manual',
    'before-backup',
    'after-backup'
  ]                         $purge_policy            = 'after-backup',
  Optional[String]          $username                = undef,
) {
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
    require => Class['holland::mongodump'],
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

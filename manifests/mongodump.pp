# Manage the [mongodump](http://docs.hollandbackup.org/docs/provider_configs/mongodump.html)
# provider for the [Holland Backup Manager](https://hollandbackup.org/)
#
# **Note**: This does not install the actual `mongodump` command since there
# are several different options for doing so. Especially with software
# collections.
#
# @summary Manage the mongodump provider for the Holland Backup Manager
#
# @param ensure
#   Should the plugin be installed or not.
#
# @param additional_options
#   Any additional options to the `mongodump` command-line utility these should
#   show up exactly as they are on the command line. e.g.: `'--gzip'`
#
# @param authentication_database
#   The database the mongo user needs to authenticate against.
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
# @param host
#   Hostname for mongodump to connect with.
#
# @param password
#   Password for mongodump to authenticate with.
#
# @param username
#   Username for mongodump to authenticate with.
#
# @example Basic
#   include holland::mongodump
class holland::mongodump (
  Enum['absent', 'present'] $ensure                  = present,
  Optional[String]          $additional_options      = undef,
  String                    $authentication_database = '',
  Integer[0]                $compression_level       = 1,
  Enum[
    'gzip',
    'gzip-rsyncable',
    'bzip2',
    'pbzip2',
    'lzop'
  ]                         $compression_method      = 'gzip',
  String                    $host                    = 'localhost',
  String                    $password                = '',
  String                    $username                = '',
){
  contain ::holland::mongodump::install
  contain ::holland::mongodump::config

  if $ensure == 'present' {
    Class['holland::mongodump::install'] -> Class['holland::mongodump::config']
  } else {
    Class['holland::mongodump::config'] -> Class['holland::mongodump::install']
  }
}

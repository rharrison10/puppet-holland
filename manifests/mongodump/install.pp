# @summary Install the Holland mongodump provider
#
# @api private
#
class holland::mongodump::install (
  Enum['absent', 'present'] $ensure = $::holland::mongodump::ensure,
){
  # https://github.com/holland-backup/holland/issues/247
  # Debian/Ubuntu have plugin bundled
  if $facts['os']['name'] in [ 'CentOS', 'RedHat', 'Scientific' ] {
    # Install the mongodump provider
    package { 'holland-mongodump':
      ensure => $ensure,
    }
  }
}

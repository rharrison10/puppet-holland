# @summary Manage the `holland-mysqldump` package
#
# @api private
#
class holland::mysqldump::install (
  Enum['absent', 'present'] $ensure = $::holland::mysqldump::ensure,
){
  # https://github.com/holland-backup/holland/issues/247
  # Debian/Ubuntu have plugin bundled
  if $facts['os']['name'] in [ 'CentOS', 'RedHat', 'Scientific' ] {
    # Install the mysqldump provider
    package { 'holland-mysqldump':
      ensure => $ensure,
    }
  }
}

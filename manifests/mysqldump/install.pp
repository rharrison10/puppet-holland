# @summary Manage the `holland-mysqldump` package
#
# @api private
#
class holland::mysqldump::install (
  Enum['absent', 'present'] $ensure = $::holland::mysqldump::ensure,
){
  # Install the mysqldump provider
  package { 'holland-mysqldump':
    ensure => $ensure,
  }
}

# @summary Install the Holland mongodump provider
#
# @api private
#
class holland::mongodump::install (
  Enum['absent', 'present'] $ensure = $::holland::mongodump::ensure,
){
  package { 'holland-mongodump':
    ensure => $ensure,
  }
}

# @summary Basic install of Holland resources
#
# @api private
#
# @example
#   include holland::install
class holland::install (
  Enum['absent', 'present'] $ensure = $::holland::ensure,
){
  # The base Holland package
  package { 'holland':
    ensure => $ensure,
  }

  $ensure_dir = $ensure ? {
    'present' => 'directory',
    default   => $ensure,
  }

  # Make sure the configuration directories have the correct permissions.
  # Slightly more secure than the package defaults
  file { [
    '/etc/holland',
    '/etc/holland/backupsets',
    '/etc/holland/providers'
  ]:
    ensure  => $ensure_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => Package['holland'],
  }

  # Make sure `holland.conf` has the correct permissions
  file { '/etc/holland/holland.conf':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Package['holland'],
  }

  # Put the Augeas lens in place.
  file { '/usr/share/augeas/lenses/dist/holland.aug':
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/holland/augeas/holland.aug',
  }

  # Its also good practice to include the test file with the lens so we'll
  # manage it as well. As of version 1.0.0-5 of the Red Hat rpm test lenses are
  # no longer included in augeas-libs so I'm going to comment this out for now.
  # file { '/usr/share/augeas/lenses/dist/tests/test_holland.aug':
  #   ensure => $ensure,
  #   owner  => 'root',
  #   group  => 'root',
  #    mode   => '0644',
  #    source => 'puppet:///modules/holland/augeas/test_holland.aug',
  # }

}

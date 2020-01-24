# @summary Basic install of Holland resources
#
# @api private
#
# @example
#   include holland::install
class holland::install (
  Enum['absent', 'present'] $ensure = $::holland::ensure,
){
  if $facts['os']['name'] in [ 'CentOS', 'RedHat', 'Scientific' ] {
    # The base Holland package
    package { 'holland':
      ensure => $ensure,
    }
  } elsif $facts['os']['name'] == 'Ubuntu' {
    require apt
    apt::source { 'holland':
      location => "https://download.opensuse.org/repositories/home:/holland-backup/x${facts['os']['name']}_${facts['os']['release']['major']}/",
      release  => '',
      repos    => './',
      notify   => Exec['install_holland_package_key'],
    }

    exec { 'install_holland_package_key':
      command     => "/usr/bin/wget -q -O - https://download.opensuse.org/repositories/home:/holland-backup/x${facts['os']['name']}_${facts['os']['release']['major']}/Release.key | apt-key add -",
      refreshonly => true,
      notify      => Class['apt::update'],
    }

    package { 'holland':
      ensure  => $ensure,
      require => Exec['install_holland_package_key'],
    }
  } else {
    fail("${facts['os']['name']} unsupported")
  }

  $ensure_dir = $ensure ? {
    'present' => 'directory',
    default   => $ensure,
  }

  $ensure_file = $ensure ? {
    'present' => 'file',
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
    ensure  => $ensure_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Package['holland'],
  }

}

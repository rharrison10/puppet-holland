# == Class: holland
#
# Common setup and resources for the {Holland Backup Manager}[http://hollandbackup.org/]. There isn't an
# {Augeas}[http://augeas.net/] lens for +holland.conf+ in the upstream project yet so we'll need to provide one ourselves to manage
# the main configuration from more than one class. Since Puppet requires +augeas-libs+ we don't need to manage the parrent
# directories since they'll already be in place.
#
# === Parameters
#
# None
#
# === Examples
#
#  include holland
#
# === Copyright
#
# Copyright 2012 Russell Harrison
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class holland {
  # The base Holland package
  package { 'holland':
    ensure => present,
  }

  # Make sure the configuration directories have the correct permissions. Slightly more secure than the package defaults
  file { ['/etc/holland', '/etc/holland/backupsets', '/etc/holland/providers']:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => Package['holland'],
  }

  # Make sure +holland.conf+ has the correct permissions
  file { '/etc/holland/holland.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Package['holland'],
  }

  # Put the Augeas lens in place.
  file { '/usr/share/augeas/lenses/dist/holland.aug':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/holland/augeas/holland.aug',
  }

  # Its also good practice to include the test file with the lens so we'll manage it as well.
  file { '/usr/share/augeas/lenses/dist/tests/test_holland.aug':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/holland/augeas/test_holland.aug',
  }
}

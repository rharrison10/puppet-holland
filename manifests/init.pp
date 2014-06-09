# == Class: holland
#
# Common setup and resources for the {Holland Backup Manager}[http://hollandbackup.org/]. There isn't an
# {Augeas}[http://augeas.net/] lens for +holland.conf+ in the upstream project yet so we'll need to provide one ourselves to manage
# the main configuration from more than one class. Since Puppet requires +augeas-libs+ we don't need to manage the parrent
# directories since they'll already be in place.
#
# === Parameters
#
# [*ensure*]
#   Wheither the resources are <tt>present</tt> or <tt>absent</tt>
#
# === Examples
#
#  include ::holland
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
class holland (
  $ensure = 'present'
) {
  if !($ensure in ['present', 'absent']) {
    fail("ensure = ${ensure} must be either 'present' or 'absent'")
  }

  # The base Holland package
  package { 'holland':
    ensure => $ensure,
  }

  $ensure_dir = $ensure ? {
    'present' => 'directory',
    default   => $ensure,
  }

  # Make sure the configuration directories have the correct permissions. Slightly more secure than the package defaults
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

  # Make sure +holland.conf+ has the correct permissions
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

  # Its also good practice to include the test file with the lens so we'll manage it as well.
  # As of version 1.0.0-5 of the Red Hat rpm test lenses are no longer included in augeas-libs
  # so I'm going to comment this out for now.
#  file { '/usr/share/augeas/lenses/dist/tests/test_holland.aug':
#    ensure => $ensure,
#    owner  => 'root',
#    group  => 'root',
#    mode   => '0644',
#    source => 'puppet:///modules/holland/augeas/test_holland.aug',
#  }

  # The <tt>holland</tt> package installs a default file with a <tt>default</tt> backup set configured but doesn't lay down a
  # configuration file for this backup set which causes <tt>holland backup</tt> to fail.  This <tt>exec</tt> removes the backup set
  # if there isn't a backup set configuration file in place for it.  All backup set defines should notify this exec.
  exec { 'holland_remove_default_set':
    command     => '/bin/sed -i -e \'s/\(^[[:space:]]*backupsets.*\),[[:space:]]*default[[:space:]]*$/\1/g\' -e \'s/\(^[[:space:]]*backupsets.*\)default[, ]*\(.*\)/\1\2/g\' /etc/holland/holland.conf',
    onlyif      => '/bin/grep -q \'backupsets.*default\' /etc/holland/holland.conf',
    unless      => '/usr/bin/test -f /etc/holland/backupsets/default.conf',
    refreshonly => true,
    require     => Package['holland'],
  }
}

# == Class: holland::mysqldump
#
# This class manages the {Holland Backup Manager}[http://hollandbackup.org/] +mysqldump+ provider.
#
# === Parameters
#
# [*ensure*]
#   Wheither the resources are <tt>present</tt> or <tt>absent</tt>
#
# === Examples
#
#  class { 'holland::mysqldump':
#    example => [ 'server1.example.org', 'server2.example.com' ]
#  }
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
class holland::mysqldump (
  $ensure = 'present'
) {
  include holland

  if !($ensure in ['present', 'absent']) {
    fail("ensure = ${ensure} must be either 'present' or 'absent'")
  }

  # There is {a bug}[https://bugzilla.redhat.com/show_bug.cgi?id=884890] with the +holland-mysqldump+ package in Fedora / EPEL where
  # it doesn't require the +mysql+ package which provides the +mysqldump+ command.  If you are backing up a remote database this
  # could cause backups to fail.  We'll include the +mysql+ package if it isn't defined elsewhere.
  if $ensure == 'present' {
    ensure_packages(['mysql'])
  }

  # Install the mysqldump provider
  package { 'holland-mysqldump':
    ensure => $ensure,
  }

  # If the +ensure+ parameter is +absent+ we need to clean up the provider configuration as well.
  if $ensure == 'absent' {
    class { 'holland::mysqldump::config':
      ensure => absent,
    }
  }
}

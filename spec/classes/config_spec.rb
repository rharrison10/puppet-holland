require 'spec_helper'

describe 'holland::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include ::holland' }

      it { is_expected.to compile }
      it {
        is_expected.to contain_augeas('/etc/holland/holland.conf')
          .with_incl('/etc/holland/holland.conf')
          .with_lens('Holland.lns')
          .with_changes([
            'set holland/backup_directory /var/spool/holland',
            'set holland/path /usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin',
            'set holland/umask 0007',
            'set logging/filename /var/log/holland/holland.log',
            'set logging/level info',
            'set holland/plugin_dirs/path[ . = "/usr/share/holland/plugins" ] /usr/share/holland/plugins',
          ])
          .with_onlyif('match holland size == 1')
          .that_requires('Class[holland::install]')
      }
    end
  end
end

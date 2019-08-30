require 'spec_helper'

describe 'holland::config::remove_default' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include ::holland' }

      it { is_expected.to compile }
      it {
        is_expected.to contain_exec('holland_remove_default_set')
          .with_unless('/usr/bin/test -f /etc/holland/backupsets/default.conf')
          .with_refreshonly(true)
          .that_requires('Package[holland]')
      }
    end
  end
end

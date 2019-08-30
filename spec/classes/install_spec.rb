require 'spec_helper'

describe 'holland::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include ::holland' }

      config_dirs = [
        '/etc/holland',
        '/etc/holland/backupsets',
        '/etc/holland/providers',
      ]

      it { is_expected.to compile }
      it { is_expected.to contain_package('holland').with_ensure('present') }
      config_dirs.each do |conf_dir|
        it {
          is_expected.to contain_file(conf_dir)
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0750')
            .that_requires('Package[holland]')
        }
      end
      it {
        is_expected.to contain_file('/etc/holland/holland.conf')
          .with_ensure('file')
          .with_owner('root')
          .with_group('root')
          .with_mode('0640')
          .that_requires('Package[holland]')
      }
    end
  end
end

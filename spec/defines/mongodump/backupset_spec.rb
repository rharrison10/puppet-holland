require 'spec_helper'

describe 'holland::mongodump::backupset' do
  let(:title) { 'mongodump_backup' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include ::holland::mongodump include ::holland' }

      it { is_expected.to compile }
      it {
        is_expected.to contain_file('/etc/holland/backupsets/mongodump_backup.conf')
          .with_ensure('file')
          .with_owner('root')
          .with_group('root')
          .with_mode('0640')
          .that_requires('Class[holland::mongodump]')
      }
      it {
        is_expected.to contain_augeas('/etc/holland/holland.conf/holland/backupsets/set mongodump_backup')
          .with_context('/files/etc/holland/holland.conf/')
          .with_incl('/etc/holland/holland.conf')
          .with_lens('Holland.lns')
          .with_changes('set holland/backupsets/set[ . = "mongodump_backup"] mongodump_backup')
          .with_onlyif('match holland size == 1')
          .that_requires('File[/etc/holland/backupsets/mongodump_backup.conf]')
          .that_notifies('Class[holland::config::remove_default]')
      }
    end
  end
end

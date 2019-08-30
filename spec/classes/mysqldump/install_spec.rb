require 'spec_helper'

describe 'holland::mysqldump::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include ::holland::mysqldump' }

      it { is_expected.to compile }
      it { is_expected.to contain_package('holland-mysqldump').with_ensure('present') }
    end
  end
end

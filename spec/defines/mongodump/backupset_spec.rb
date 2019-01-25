require 'spec_helper'

describe 'holland::mongodump::backupset' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include ::holland::mongodump include ::holland' }

      it { is_expected.to compile }
    end
  end
end

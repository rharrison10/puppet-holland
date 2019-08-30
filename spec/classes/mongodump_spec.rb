require 'spec_helper'

describe 'holland::mongodump' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include ::holland' }

      it { is_expected.to compile }
      it { is_expected.to contain_class('holland::mongodump::install') }
      it { is_expected.to contain_class('holland::mongodump::config') }
    end
  end
end

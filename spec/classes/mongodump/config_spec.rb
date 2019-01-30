require 'spec_helper'

describe 'holland::mongodump::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include ::holland::mongodump' }

      it { is_expected.to compile }
    end
  end
end

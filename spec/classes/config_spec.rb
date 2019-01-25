require 'spec_helper'

describe 'holland::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { "include ::holland" }

      it { is_expected.to compile }
    end
  end
end

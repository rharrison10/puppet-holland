require 'spec_helper'

describe 'holland' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('holland::install') }
      it { is_expected.to contain_class('holland::config') }

    end
  end
end

require 'spec_helper'

describe 'windowmanager' do
context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('windowmanager') }
        it { is_expected.to contain_class('mozilla::firefox') }
      end
    end
  end
end

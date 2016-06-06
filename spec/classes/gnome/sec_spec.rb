require 'spec_helper'

describe 'windowmanager::gnome::sec' do
context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }
        if facts[:operatingsystemmajrelease].to_s <= '6'
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('windowmanager::gnome::sec') }
          it { is_expected.to contain_gconf('screensaver_enabled') }
          it { is_expected.to contain_gconf('screensaver_timeout') }
          it { is_expected.to contain_gconf('screensaver_lock') }
        end
      end
    end
  end
end

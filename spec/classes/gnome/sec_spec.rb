require 'spec_helper'

describe 'windowmanager::gnome::sec' do
context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts.merge( { :gdm_version => '3.20.1' } ) }
        it { is_expected.to compile.with_all_deps }
        if os_facts[:operatingsystemmajrelease].to_s <= '6'
          it { is_expected.to create_class('windowmanager::gnome::sec') }
          it { is_expected.to contain_gconf('screensaver_enabled') }
          it { is_expected.to contain_gconf('screensaver_timeout') }
          it { is_expected.to contain_gconf('screensaver_lock') }
        end
        context 'with gdm version < 3' do
          let(:facts) { os_facts.merge( { :gdm_version => '2.0' } ) }
          it { is_expected.to_not contain_class('windowmanager::gnome::dconf') }
        end
        context 'with gdm version >= 3' do
          let(:facts) { os_facts.merge( { :gdm_version => '3.0' } ) }
          it { is_expected.to contain_class('windowmanager::gnome::dconf') }
        end
      end
    end
  end
end

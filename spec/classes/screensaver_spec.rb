require 'spec_helper'

describe 'gnome::screensaver' do
context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts[:gdm_version] = '3.20.1'
          os_facts
        end

        it { is_expected.to compile.with_all_deps }

        if os_facts[:os][:release][:major] == 6
          it { is_expected.to create_class('gnome::screensaver') }
          it { is_expected.to contain_gconf('screensaver_enabled') }
          it { is_expected.to contain_gconf('screensaver_timeout') }
          it { is_expected.to contain_gconf('screensaver_lock') }
        end

        context 'with gdm version < 3' do
          let(:facts) do
            os_facts[:gdm_version] = '2.0'
            os_facts
          end
          it { is_expected.to_not contain_class('gnome::dconf') }
        end

        context 'with gdm version >= 3' do
          let(:facts) do
            os_facts[:gdm_version] = '3.0'
            os_facts
          end
          it { is_expected.to contain_class('gnome::dconf') }
        end

      end
    end
  end
end

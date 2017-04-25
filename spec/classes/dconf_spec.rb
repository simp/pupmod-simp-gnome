require 'spec_helper'

describe 'gnome::dconf' do
  supported_os = on_supported_os.delete_if { |e| e =~ /-6-/ } #TODO do this right
  supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('gnome::dconf') }
        it { is_expected.to create_file('/etc/dconf/profile/user').with_content("system-db:simp\nuser-db:user\nsystem-db:local\nsystem-db:site\nsystem-db:distro") }
        it { is_expected.to create_polkit__authorization__basic_policy('Allow anyone to shutdown system') }
        it { is_expected.to create_polkit__authorization__basic_policy('Allow anyone to restart system') }

        it { is_expected.to create_file('/etc/dconf/db/simp.d').with_ensure('directory') }
        it { is_expected.to create_file('/etc/dconf/db/simp.d/locks').with_ensure('directory') }
        it { is_expected.to create_file('/etc/dconf/db/gdm.d').with_ensure('directory') }
        it { is_expected.to create_file('/etc/dconf/db/gdm.d/locks').with_ensure('directory') }

        [
          'automount',
          'automount_open',
          'autorun',
          'ctrl_alt_del',
          'shutdown_login_screen',
          'power_button_action',
          'screen_saver_idle',
          'screen_saver_idle_time',
          'lock_enabled',
          'lock_delay',
          'banner_text'
        ].each do |dconf|
          it { is_expected.to create_gnome__dconf__add(dconf) }
        end
      end

    end
  end
end

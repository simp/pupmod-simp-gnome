require 'spec_helper'

packages_el6 = [
  'alacarte',
  'at-spi',
  'GConf2',
  'gnome-panel',
  'gnome-screensaver',
  'gnome-session-xsession',
  'gnome-session',
  'gnome-terminal',
  'im-chooser',
  'libgnome',
  'libgnomeui',
  'nautilus-open-terminal',
  'nautilus',
  'orca',
  'yelp'
]

packages_el7 = [
  'at-spi2-atk',
  'control-center',
  'dconf',
  'gnome-desktop3',
  'gnome-session-xsession',
  'gnome-session',
  'gnome-terminal',
  'gnome-user-docs',
  'im-chooser',
  'libgnome',
  'libgnomeui',
  'nautilus',
  'orca',
  'yelp',
]

describe 'gnome' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        if os_facts[:os][:release][:major] >= '7'
          os_facts[:gdm_version] = '3.20.1'
        else
          os_facts[:gdm_version] = '2.20.1'
        end
        os_facts
      end

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('gnome') }

        # gnome::install
        if os_facts[:os][:release][:major] >= '7'
          packages = packages_el7
        else
          packages = packages_el6
        end
        packages.each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('installed') }
        end

        # gnome::config
        # gnome::config::gnome2
        if os_facts[:os][:release][:major] == '6'
          it { is_expected.to create_gconf('screensaver_enabled').with({
            value: true,
            type: 'bool',
            schema: 'mandatory'
          }) }
          it { is_expected.to create_gconf('screensaver_timeout').with({
            value: 15,
            type: 'int',
          }) }
          it { is_expected.to create_gconf('screensaver_lock').with({
            value: true,
            type: 'bool',
            schema: 'mandatory'
          }) }
        end

        # gnome::config::gnome3
        if os_facts[:os][:release][:major] >= '7'
          it { is_expected.to create_file('/etc/dconf/profile/user').with_content(
           'user-db:user
            system-db:simp
            system-db:local
            system-db:site
            system-db:distro'.gsub(/^\s+/,'')
          ) }

          it { is_expected.to create_polkit__authorization__basic_policy('Allow anyone to shutdown system') }
          it { is_expected.to create_polkit__authorization__basic_policy('Allow anyone to restart system') }
          it { is_expected.to create_file('/etc/dconf/db/gdm.d').with_ensure('directory') }
          it { is_expected.to create_file('/etc/dconf/db/gdm.d/locks').with_ensure('directory') }
          # it { require 'pry';binding.pry }
          it { is_expected.to create_gnome__config__dconf('gdm org/gnome/login-screen').with({
            :ensure        => 'present',
            :profile       => 'gdm',
            :path          => 'org/gnome/login-screen',
            :settings_hash => {
              'disable-restart-buttons' => { 'value' => true },
              'banner-message-enable'   => { 'value' => true },
            }
          }) }

          # data structure driven
          it { is_expected.to create_file('/etc/dconf/db/simp.d').with_ensure('directory') }
          it { is_expected.to create_file('/etc/dconf/db/simp.d/locks').with_ensure('directory') }
          it { is_expected.to create_gnome__config__dconf('simp org/gnome/desktop/media-handling').with({
            :ensure        => 'present',
            :profile       => 'simp',
            :path          => 'org/gnome/desktop/media-handling',
            :settings_hash => {
              'automount'       => { 'value' => false },
              'automount-open'  => { 'value' => false },
              'automount-never' => { 'value' => false },
            }
          }) }
          it { is_expected.to create_gnome__config__dconf('simp org/gnome/settings-daemon/plugins/media-keys').with({
            :settings_hash => {
              'logout' => { 'value' => '' },
            }
          }) }
          it { is_expected.to create_gnome__config__dconf('simp org/gnome/settings-daemon/plugins/power').with({
            :settings_hash => {
              'active' => { 'value' => false },
            }
          }) }
          it { is_expected.to create_gnome__config__dconf('simp org/gnome/desktop/session').with({
            :settings_hash => {
              'idle-delay' => { 'value' => 'uint32 900' },
            }
          }) }
          it { is_expected.to create_gnome__config__dconf('simp org/gnome/desktop/screensaver').with({
            :settings_hash => {
              'idle-activation-enabled' => { 'value' => true },
              'lock-enabled'            => { 'value' => true },
              'lock-delay'              => { 'value' => 0 },
            }
          }) }
        end

      end

      if os_facts[:os][:release][:major] >= '7'
        context 'with a different dconf_profile_hierarchy' do
          let(:params) {{ dconf_profile_hierarchy: ['user-db:user','system-db:test'] }}
          it { is_expected.to create_file('/etc/dconf/profile/user').with_content(
           'user-db:user
            system-db:test'.gsub(/^\s+/,'')
          ) }
        end
        context 'with an overridden dconf_hash' do
          let(:params) {{
            'dconf_hash' => {
              'simp' => {
                'org/gnome/desktop/background' => {
                  'picture-uri' => { 'value' => '/wallpaper/path' }
                }
              }
            }
          }}
          it { is_expected.to create_file('/etc/dconf/db/simp.d').with_ensure('directory') }
          it { is_expected.to create_file('/etc/dconf/db/simp.d/locks').with_ensure('directory') }
          it { is_expected.to create_gnome__config__dconf('simp org/gnome/desktop/background').with_profile('simp') }
        end
        context 'with multiple profiles in dconf_hash' do
          let(:params) {{
            'dconf_hash' => {
              'simp' => {
                'org/gnome/desktop/background' => {
                  'picture-uri' => { 'value' => '/wallpaper/path' }
                }
              },
              'site' => {
                'system/proxy/http' => {
                  'host' => { 'value' => '0.0.0.0' }
                }
              }
            }
          }}
          it { is_expected.to create_file('/etc/dconf/db/simp.d').with_ensure('directory') }
          it { is_expected.to create_file('/etc/dconf/db/simp.d/locks').with_ensure('directory') }
          it { is_expected.to create_file('/etc/dconf/db/site.d').with_ensure('directory') }
          it { is_expected.to create_file('/etc/dconf/db/site.d/locks').with_ensure('directory') }
          it { is_expected.to create_gnome__config__dconf('simp org/gnome/desktop/background').with_profile('simp') }
          it { is_expected.to create_gnome__config__dconf('site system/proxy/http').with_profile('site') }
        end

      end

      context 'with a more populated packages' do
        let(:params) {{ :packages => {
          'good-package' => { 'ensure' => '1.2.3' },
          'gnome-terminal' => :undef
        } }}
        it { is_expected.to create_package('good-package').with_ensure('1.2.3') }
        it { is_expected.to create_package('gnome-terminal').with_ensure('installed') }
      end

    end
  end
end

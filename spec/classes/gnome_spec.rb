require 'spec_helper'

packages_common = [
  'at-spi2-atk',
  'dconf',
  'gnome-desktop3',
  'gnome-session-xsession',
  'gnome-session',
  'gnome-terminal',
  'gnome-user-docs',
  'nautilus',
  'orca',
  'yelp',
]

packages_el8 = [
  'gnome-control-center',
]

packages_el7 = [
  'control-center',
  'im-chooser',
  'libgnome',
  'libgnomeui',
]

packages_el7_4 = packages_el7 + [ 'libxkbcommon-x11' ]

describe 'gnome' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('gnome') }

        # gnome::install
        # rubocop:disable RSpec/RepeatedExample
        packages_common.each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure(%r{\A(present|installed)\Z}) }
        end
        if os_facts[:os][:release][:major] == '7'
          packages_el7.each do |pkg|
            it { is_expected.to contain_package(pkg).with_ensure(%r{\A(present|installed)\Z}) }
          end
        end
        if os_facts[:os][:release][:major] == '8'
          packages_el8.each do |pkg|
            it { is_expected.to contain_package(pkg).with_ensure(%r{\A(present|installed)\Z}) }
          end
        end
        if os_facts[:os][:release][:full] == '7.4'
          packages_el7_4.each do |pkg|
            it { is_expected.to contain_package(pkg).with_ensure(%r{\A(present|installed)\Z}) }
          end
        end
        # rubocop:enable RSpec/RepeatedExample

        # gnome::config
        it { is_expected.to create_polkit__authorization__basic_policy('Allow anyone to shutdown system') }
        it { is_expected.to create_polkit__authorization__basic_policy('Allow anyone to restart system') }

        # data structure driven
        it {
          is_expected.to create_dconf__settings('GNOME dconf settings: simp_gnome').with(
            ensure: 'present',
            profile: 'simp_gnome',
            settings_hash: {
              'org/gnome/desktop/media-handling' => {
                'automount' => { 'value' => false },
                'automount-open' => { 'value' => false },
                'autorun-never' => { 'value' => true },
              },
              'org/gnome/settings-daemon/plugins/media-keys' => {
                'logout' => { 'value' => "''" },
              },
              'org/gnome/settings-daemon/plugins/power' => {
                'active' => { 'value' => false },
              },
              'org/gnome/desktop/session' => {
                'idle-delay' => { 'value' => 'uint32 900' },
              },
              'org/gnome/desktop/lockdown' => {
                'disable-lock-screen' => { 'value' => false },
                'disable-show-password' => { 'value' => true },
              },
              'org/gnome/desktop/screensaver' => {
                'idle-activation-enabled' => { 'value' => true },
                'lock-enabled' => { 'value' => true },
                'lock-delay' => { 'value' => 'uint32 0' },
              },
            },
          )
        }
      end

      context 'with a more populated packages' do
        let(:params) do
          {
            packages: {
              'good-package' => { 'ensure' => '1.2.3' },
              'gnome-terminal' => :undef,
            },
          }
        end

        it { is_expected.to create_package('good-package').with_ensure('1.2.3') }
        it { is_expected.to create_package('gnome-terminal').with_ensure(%r{\A(present|installed)\Z}) }
      end

      context 'with an overridden dconf_hash' do
        let(:params) do
          {
            'dconf_hash' => {
              'simp' => {
                'org/gnome/desktop/background' => {
                  'picture-uri' => { 'value' => '/wallpaper/path' },
                },
              },
            },
          }
        end

        it { is_expected.to create_dconf__settings('GNOME dconf settings: simp').with_profile('simp') }
      end
      context 'with multiple profiles in dconf_hash' do
        let(:params) do
          {
            'dconf_hash' => {
              'simp' => {
                'org/gnome/desktop/background' => {
                  'picture-uri' => { 'value' => '/wallpaper/path' },
                },
              },
              'site' => {
                'system/proxy/http' => {
                  'host' => { 'value' => '0.0.0.0' },
                },
              },
            },
          }
        end

        it { is_expected.to create_dconf__settings('GNOME dconf settings: simp').with_profile('simp') }

        it { is_expected.to create_dconf__settings('GNOME dconf settings: site').with_profile('site') }
      end
    end
  end
end

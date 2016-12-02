require 'spec_helper'

describe 'gnome' do
context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts.merge( { :gdm_version => '3.20.1' } ) }

        let(:params) { {:enable_screensaver => true} }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('gnome') }
        it { is_expected.to contain_class('gnome::screensaver') }
        if os_facts[:operatingsystemmajrelease].to_s > '6'
          $package_list = [
            'alacarte',
            'at-spi2-atk',
            'control-center',
            'gnome-backgrounds',
            'gnome-color-manager',
            'gnome-classic-session',
            'gnome-desktop3',
            'gnome-session',
            'gnome-session-xsession',
            'gnome-settings-daemon',
            'gnome-terminal',
            'im-chooser',
            'libgnome',
            'libgnomeui',
            'metacity',
            'nautilus',
            'nautilus-open-terminal',
            'orca',
            'yelp',
          ]
        else
          $package_list = [
            'alacarte',
            'at-spi',
            'control-center',
            'gnome-applets',
            'gnome-mag',
            'gnome-panel',
            'gnome-power-manager',
            'gnome-screensaver',
            'gnome-session',
            'gnome-terminal',
            'gnome-user-docs',
            'gnome-utils',
            'im-chooser',
            'nautilus',
            'nautilus-open-terminal',
            'orca',
            'sabayon-apply',
            'yelp'
          ]
        end
        $package_list.each do |pkg|
          it { is_expected.to contain_package(pkg) }
        end
        it { is_expected.to contain_package('gdm') }
      end
    end
  end
end

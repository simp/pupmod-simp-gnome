require 'spec_helper'

describe 'gnome' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts[:gdm_version] = '3.20.1'
          os_facts
        end

        let(:params) { {:enable_screensaver => true} }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('gnome') }
        it { is_expected.to contain_class('gnome::screensaver') }
        if os_facts[:os][:release][:major] >= '7'
          $package_list = [
            'alacarte',
            'at-spi2-atk',
            'control-center',
            'gnome-desktop3',
            'gnome-session',
            'gnome-session-xsession',
            'gnome-terminal',
            'gnome-user-docs',
            'im-chooser',
            'libgnome',
            'libgnomeui',
            'nautilus',
            'orca',
            'yelp',
          ]
        else
          $package_list = [
            'alacarte',
            'at-spi',
            'gnome-panel',
            'gnome-session',
            'gnome-session-xsession',
            'gnome-terminal',
            'im-chooser',
            'libgnome',
            'libgnomeui',
            'nautilus',
            'nautilus-open-terminal',
            'orca',
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

require 'spec_helper'

describe 'gnome::dconf::add', :type => :define do
context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }
        let(:title) { 'default' }
        let(:params) do
          {
            :profile => 'gdm',
            :key     => 'lock-delay',
            :value   => true,
            :path    => 'org/gnome/desktop/screensaver' 
          }
        end

        it { is_expected.to contain_file('/etc/dconf/db/gdm.d/default').with(
          :notify => 'Exec[dconf_update_default]'
        )}
        it { is_expected.to contain_exec('dconf_update_default') }
        context 'with lock=true' do
          it { is_expected.to contain_file('/etc/dconf/db/gdm.d/locks/default').with(
            :content => '/org/gnome/desktop/screensaver/lock-delay',
            :notify  => 'Exec[dconf_update_default]'
          )}
        end
        context 'with lock=false' do
          let(:params) do
            {
              :profile => 'gdm',
              :key     => 'lock-delay',
              :value   => true,
              :path    => 'org/gnome/desktop/screensaver',
              :lock    => false
            }
          end
          it { is_expected.to contain_file('/etc/dconf/db/gdm.d/locks/default').with_ensure('absent') }
        end
      end
    end
  end
end

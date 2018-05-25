require 'spec_helper'

describe 'gnome::dconf', :type => :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end


      context 'with minimal parameters' do
        let(:title) { 'Enable lock delay' }
        let(:params) {{
          :ensure      => 'present',
          :settings_hash => { 'lock-delay' => { 'value' => true } },
          :profile     => 'gdm',
          :path        => 'org/gnome/desktop/screensaver'
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/dconf/db/gdm.d/enable_lock_delay') }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/enable_lock_delay [org/gnome/desktop/screensaver] lock-delay') \
          .with_value('true') }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/enable_lock_delay [org/gnome/desktop/screensaver] lock-delay').with({
          :section => 'org/gnome/desktop/screensaver',
          :setting => 'lock-delay',
          :value   => true
        }) }
        it { is_expected.to create_file('/etc/dconf/db/gdm.d/locks/enable_lock_delay') \
          .with_content('/org/gnome/desktop/screensaver/lock-delay') }
      end

      context 'a setting with many items' do
        let(:title) { 'Set wallpaper' }
        let(:params) {{
          :ensure        => 'present',
          :profile       => 'gdm',
          :path          => 'org/gnome/desktop/background',
          :settings_hash => {
            'picture-uri'     => { 'value' => '/home/test/Pictures/puppies.jpg' },
            'picture-options' => { 'value' => 'scaled' },
            'primary-color'   => { 'value' => '000000' },
          }
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/set_wallpaper [org/gnome/desktop/background] picture-uri') \
          .with_value('/home/test/Pictures/puppies.jpg') }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/set_wallpaper [org/gnome/desktop/background] picture-options') \
          .with_value('scaled') }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/set_wallpaper [org/gnome/desktop/background] primary-color') \
          .with_value('000000') }
        it { is_expected.to create_file('/etc/dconf/db/gdm.d/locks/set_wallpaper').with_content(<<-EOF.gsub(/^\s+/,'').strip
          /org/gnome/desktop/background/picture-uri
          /org/gnome/desktop/background/picture-options
          /org/gnome/desktop/background/primary-color
          EOF
        ) }
      end

      context 'with one setting with lock => false' do
        let(:title) { 'Enable lock delay' }
        let(:params) {{
          :ensure        => 'present',
          :settings_hash => { 'lock-delay' => { 'value' => true, 'lock' => false } },
          :profile       => 'gdm',
          :path          => 'org/gnome/desktop/screensaver',
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/enable_lock_delay [org/gnome/desktop/screensaver] lock-delay') \
          .with_value('true') }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/enable_lock_delay [org/gnome/desktop/screensaver] lock-delay').with({
          :section => 'org/gnome/desktop/screensaver',
          :setting => 'lock-delay',
          :value   => true
        }) }
        it { is_expected.to create_file('/etc/dconf/db/gdm.d/locks/enable_lock_delay') \
          .with_ensure('absent') }
      end

      context 'a setting with many items, and one unlocked' do
        let(:title) { 'Set wallpaper' }
        let(:params) {{
          :ensure        => 'present',
          :profile       => 'gdm',
          :path          => 'org/gnome/desktop/background',
          :settings_hash => {
            'picture-uri'     => { 'value' => '/home/test/Pictures/puppies.jpg', 'lock' => false },
            'picture-options' => { 'value' => 'scaled' , 'lock' => :undef },
            'primary-color'   => { 'value' => '000000'},
          }
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/set_wallpaper [org/gnome/desktop/background] picture-uri') \
          .with_value('/home/test/Pictures/puppies.jpg') }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/set_wallpaper [org/gnome/desktop/background] picture-options') \
          .with_value('scaled') }
        it { is_expected.to create_ini_setting('/etc/dconf/db/gdm.d/set_wallpaper [org/gnome/desktop/background] primary-color') \
          .with_value('000000') }
        it { is_expected.to create_file('/etc/dconf/db/gdm.d/locks/set_wallpaper').with_content(<<-EOF.gsub(/^\s+/,'').strip
          /org/gnome/desktop/background/picture-options
          /org/gnome/desktop/background/primary-color
          EOF
        ) }
      end

    end
  end
end

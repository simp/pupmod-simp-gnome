require 'spec_helper'

describe 'gnome::dconf::add', :type => :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts){ facts }
      let(:title) { 'default' }

      context 'with minimal params' do
        let(:params) {{
          :profile => 'gdm',
          :key     => 'lock-delay',
          :value   => true,
          :path    => 'org/gnome/desktop/screensaver'
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_gnome__config__dconf('default').with({
          :ensure        => 'present',
          :profile       => 'gdm',
          :path          => 'org/gnome/desktop/screensaver',
          :base_dir      => '/etc/dconf/db',
          :settings_hash => {
            'lock-delay' => { 'value' => true, 'lock' => true }
          }
        }) }
      end

      # it { require 'pry'; binding.pry }
      context 'with lock => false' do
        let(:params) {{
          :profile => 'gdm',
          :key     => 'lock-delay',
          :value   => true,
          :path    => 'org/gnome/desktop/screensaver',
          :lock    => false
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_gnome__config__dconf('default').with({
          :ensure        => 'present',
          :profile       => 'gdm',
          :path          => 'org/gnome/desktop/screensaver',
          :base_dir      => '/etc/dconf/db',
          :settings_hash => {
            'lock-delay' => { 'value' => true, 'lock' => false }
          }
        }) }
      end
    end
  end
end

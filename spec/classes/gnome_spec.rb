require 'spec_helper'

describe 'windowmanager::gnome' do

  let(:params) { {:include_sec => true} }

  it { is_expected.to create_class('windowmanager::gnome') }
  it { is_expected.to contain_class('windowmanager::gnome::sec') }

  @package = [
    'alacarte', 'at-spi', 'control-center', 'gnome-applets', 'gnome-mag', 'gnome-panel',
    'gnome-power-manager', 'gnome-screensaver', 'gnome-session', 'gnome-terminal',
    'gnome-user-docs', 'gnome-utils', 'im-chooser', 'nautilus', 'nautilus-open-terminal',
    'orca', 'sabayon-apply', 'yelp'
  ]
  @package.each do |pkg|
    it { is_expected.to contain_package(pkg) }
  end


end

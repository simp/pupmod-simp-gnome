require 'spec_helper'

describe 'windowmanager::gnome::sec' do

  it { is_expected.to create_class('windowmanager::gnome::sec') }

  it { is_expected.to contain_gconf('screensaver_enabled') }
  it { is_expected.to contain_gconf('screensaver_timeout') }
  it { is_expected.to contain_gconf('screensaver_lock') }

end

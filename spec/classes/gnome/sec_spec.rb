require 'spec_helper'

describe 'windowmanager::gnome::sec' do

  it { should create_class('windowmanager::gnome::sec') }

  it { should contain_gconf('screensaver_enabled') }
  it { should contain_gconf('screensaver_timeout') }
  it { should contain_gconf('screensaver_lock') }

end

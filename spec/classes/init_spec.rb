require 'spec_helper'

describe 'windowmanager' do

  it { should create_class('windowmanager') }
  it { should contain_class('mozilla::firefox') }

end

require 'spec_helper'

describe 'windowmanager' do

  it { is_expected.to create_class('windowmanager') }
  it { is_expected.to contain_class('mozilla::firefox') }

end

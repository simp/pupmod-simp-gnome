require 'spec_helper_acceptance'

test_name 'gnome class'

describe 'gnome class' do
  let(:manifest) {
    <<-EOS
      include '::gnome'
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      context 'default parameters' do
        it 'should work with no errors' do
           apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be idempotent' do
          apply_manifest_on(host, manifest, {:catch_changes => true})
        end

        it 'should have GNOME installed' do
          expect(host.check_for_command('gnome-session')).to be true
        end
      end
    end
  end
end

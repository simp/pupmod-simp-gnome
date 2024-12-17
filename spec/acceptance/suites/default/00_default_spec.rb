require 'spec_helper_acceptance'

test_name 'gnome class'

describe 'gnome class' do
  let(:manifest) do
    <<-EOS
      include '::gnome'
    EOS
  end

  hosts.each do |host|
    context "on #{host}" do
      context 'default parameters' do
        it 'works with no errors' do
          apply_manifest_on(host, manifest, catch_failures: true)
        end

        it 'is idempotent' do
          apply_manifest_on(host, manifest, { catch_changes: true })
        end

        it 'has GNOME installed' do
          expect(host.check_for_command('gnome-session')).to be true
        end
      end
    end
  end
end

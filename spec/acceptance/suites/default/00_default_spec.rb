require 'spec_helper_acceptance'

test_name 'gnome class'

describe 'gnome class' do
  let(:manifest) do
    <<~EOS
      include 'gnome'
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
          # NOTE: Beaker's check_for_command relies on the `which` binary, which
          # is not present in the minimal EL8/EL9 base images (it is only pulled
          # in as a transitive dependency on EL10). Probe for the binary with the
          # `command -v` shell builtin instead so this works on every platform.
          result = on(host, 'command -v gnome-session', accept_all_exit_codes: true)
          expect(result.exit_code).to eq(0)
        end
      end
    end
  end
end

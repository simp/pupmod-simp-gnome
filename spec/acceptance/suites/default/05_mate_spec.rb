require 'spec_helper_acceptance'

test_name 'gnome with MATE'

describe 'gnome with MATE' do
  let(:manifest) {
    <<-EOS
      include '::gnome'
    EOS
  }

  let(:hieradata) {{
    'gnome::enable_mate' => true
  }}

  hosts.each do |host|
    context "on #{host}" do
      context 'default parameters' do
        it 'should work with no errors' do
          set_hieradata_on(host, hieradata)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be idempotent' do
          apply_manifest_on(host, manifest, {:catch_changes => true})
        end

        if host.host_hash[:roles].include?('mate_enabled')
          it 'should have MATE installed' do
            host.check_for_command('mate-session').should be true
          end
        end
      end
    end
  end
end

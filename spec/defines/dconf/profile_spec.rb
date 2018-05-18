require 'spec_helper'

describe 'gnome::dconf::profile', :type => :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'with a set of entries' do
        let(:title) { 'user' }
        let(:params) {{
          :entries => {
            'user' => {
              'type' => 'user',
              'order' => 1
            },
            'test' => {
              'type' => 'system',
              'order' => 200
            },
            'test2' => {
              'type' => 'service'
            },
            '/some/file/path' => {
              'type' => 'file'
            }
          },
          :target => '/tmp/foo'
        }}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to create_file(params[:target]).with_ensure('directory') }

        it { is_expected.to create_concat("#{params[:target]}/#{title}").with_order('numeric') }

        it {
          is_expected.to create_concat__fragment("gnome::dconf::profile::#{title}::user").with({
            :target  => "#{params[:target]}/#{title}",
            :order   => params[:entries]['user']['order'],
            :content => "user-db:user\n"
          })
        }

        it {
          is_expected.to create_concat__fragment("gnome::dconf::profile::#{title}::test").with({
            :target  => "#{params[:target]}/#{title}",
            :order   => params[:entries]['test']['order'],
            :content => "system-db:test\n"
          })
        }

        it {
          is_expected.to create_concat__fragment("gnome::dconf::profile::#{title}::test2").with({
            :target  => "#{params[:target]}/#{title}",
            :order   => 15,
            :content => "service-db:test2\n"
          })
        }

        it {
          is_expected.to create_concat__fragment("gnome::dconf::profile::#{title}::/some/file/path").with({
            :target  => "#{params[:target]}/#{title}",
            :order   => 15,
            :content => "file-db:/some/file/path\n"
          })
        }
      end
    end
  end
end

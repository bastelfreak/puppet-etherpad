require 'spec_helper'

describe 'etherpad' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'etherpad class without any parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_vcsrepo('/opt/etherpad') }
          it { is_expected.to contain_file('/lib/systemd/system/etherpad.service') }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r|^\s*"users": {$|) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').without_content(%r{ldapauth}) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').without_content(%r{ep_button_link}) }
          it { is_expected.to contain_service('etherpad') }
          it { is_expected.to contain_user('etherpad') }
          it { is_expected.to contain_group('etherpad') }
        end
      end
    end
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'etherpad class with ldapauth set' do
          let(:params) do
            {
              ldapauth: {
                'url'                => 'ldap://ldap.foobar.com',
                'accountBase'        => 'o=staff,o=foo,dc=bar,dc=com',
                'groupAttributeIsDN' => false
              },
              users: {
                'test_user' => {
                  'password' => 's3cr3t',
                  'is_admin' => true
                }
              }
            }
          end

          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r|^\s*"users": {$|) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r|^\s*"ldapauth": {$|) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r{^\s*"url": "ldap:\/\/ldap.foobar.com",$}) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r{^\s*"accountBase": "o=staff,o=foo,dc=bar,dc=com",$}) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r{^\s*"groupAttributeIsDN": false,$}) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').without_content(%r{test_user}) }
        end

        context 'etherpad class with button_link set' do
          let(:params) do
            {
              button_link: {
                'text'   => 'Link Button',
                'link'   => 'http://example.com/pad-lister',
                'before' => "li[data-key='showTimeSlider']"
              }
            }
          end

          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r|^\s*"ep_button_link": {$|) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r{^\s*"text": "Link Button",$}) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r{^\s*"link": "http://example\.com/pad-lister",$}) }
          it { is_expected.to contain_file('/opt/etherpad/settings.json').with_content(%r{^\s*"before": "li\[data-key='showTimeSlider'\]"$}) }
        end

        context 'etherpad class with all parameters set' do
          let(:params) do
            {
              ensure: 'present',
              service_name: 'etherpad',
              service_ensure: 'running',
              service_provider: facts[:service_provider],
              manage_user: true,
              manage_abiword: false,
              abiword_path: '/usr/bin/abiword',
              manage_tidy: false,
              tidy_path: '/usr/bin/tidy',
              user: 'etherpad',
              group: 'etherpad',
              root_dir: '/opt/etherpad',
              source: 'https://github.com/ether/etherpad-lite.git',

              # Db
              database_type: 'dirty',
              database_host: 'localhost',
              database_user: 'etherpad',
              database_name: 'etherpad',
              database_password: 'etherpad',

              # Network
              ip: '*',
              port: 9001,
              trust_proxy: false,

              # Performance
              max_age: 21_600,
              minify: true,

              # Config
              button_link: {
                'text'   => 'Link Button',
                'link'   => 'http://example.com/pad-lister',
                'before' => "li[data-key='showTimeSlider']"
              },
              ldapauth: {
                'url'                => 'ldap://ldap.foobar.com',
                'groupAttributeIsDN' => true
              },
              require_session: false,
              edit_only: false,
              require_authentication: false,
              require_authorization: false,
              pad_title: :undef,
              default_pad_text: 'Welcome to etherpad!',

              # Users
              'users' => {
                'admin' => {
                  'password' => 's3cr3t',
                  'is_admin' => true
                },
                'user' => {
                  'password' => 'secret',
                  'is_admin' => false
                }
              },

              # Logging
              logconfig_file: true,
              logconfig_file_filename: '/var/log/etherpad.log',
              logconfig_file_max_log_size: 1024,
              logconfig_file_backups: 3,
              logconfig_file_category: 'etherpad'

            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/var/log/etherpad.log') }
        end
      end
    end
  end
end

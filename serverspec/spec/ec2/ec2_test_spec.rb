require 'spec_helper'

app_dir = "/var/www/raisetech-live8-sample-app"

# ---------------------------------------------------------
# packageがインストールされていること
# ---------------------------------------------------------
packages = ['git',
            'make',
            'gcc-c++',
            'patch',
            'openssl-devel',
            'libyaml-devel',
            'libffi-devel',
            'libicu-devel',
            'libxml2',
            'libxslt',
            'libxml2-devel',
            'libxslt-devel',
            'zlib-devel',
            'readline-devel',
            'ImageMagick',
            'ImageMagick-devel',
            'mysql-community-devel',
            'mysql-community-server',
            'nginx'
            ]

packages.each do |package|
    describe package(package) do
        it { should be_installed }
    end
end

# ---------------------------------------------------------
# バージョンが正しくインストールされていること
# ---------------------------------------------------------
describe command('ruby -v') do
    let(:path) { '/home/ec2-user/.rbenv/shims:$PATH' }
    its(:stdout) { should match(/#{Regexp.escape('ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-linux]')}/) }
end

describe command('rails -v') do
    let(:path) { '/home/ec2-user/.rbenv/shims:$PATH' }
    its(:stdout) { should match /Rails 7\.0\.4/ }
end

describe package('bundler') do
    let(:path) { '/home/ec2-user/.rbenv/shims:$PATH' }
    it { should be_installed.by('gem').with_version('2.3.14') }
end

# ---------------------------------------------------------
# アプリのディレクトリが指定した場所に存在すること
# ---------------------------------------------------------
describe file("#{app_dir}") do
    it { should be_directory }
end

# ---------------------------------------------------------
# nginxのconfファイルが存在すること
# ---------------------------------------------------------
describe file('/etc/nginx/conf.d/raisetech-live8-sample-app.conf') do
    it { should be_file }
end

# ---------------------------------------------------------
# config/environments/development.rbに指定した文字列が存在すること
# ---------------------------------------------------------
describe file('/var/www/raisetech-live8-sample-app/config/environments/development.rb') do
    its(:content) { should match '  config.active_storage.service = :amazon' }
    its(:content) { should match "\ \ config\.hosts\ \<\<\ \"" + ENV['AWS_ALB'] + "\"" }
end

# ---------------------------------------------------------
# config/unicorn.rbに指定した文字列が存在すること
# ---------------------------------------------------------
describe file('/var/www/raisetech-live8-sample-app/config/unicorn.rb') do
    its(:content) { should match "listen '#{app_dir}/unicorn.sock'" }
    its(:content) { should match "pid    '#{app_dir}/unicorn.pid'" }
end

# ---------------------------------------------------------
# config/storage.ymlに指定した文字列が存在すること
# ---------------------------------------------------------
describe file('/var/www/raisetech-live8-sample-app/config/storage.yml') do
    its(:content) { should match (/#{Regexp.escape(" access_key_id: <%= ENV['S3_IAM_ACCESS_KEY'] %>")}/) }
    its(:content) { should match (/#{Regexp.escape(" secret_access_key: <%= ENV['S3_IAM_SECRET_ACCESS_KEY'] %>")}/) }
    its(:content) { should match (/#{Regexp.escape(" bucket: <%= ENV['S3_BUCKET_NAME'] %>")}/) }
end

# ---------------------------------------------------------
# portが正しくリッスンしていること
# ---------------------------------------------------------
describe port(80) do
    it { should be_listening }
end

describe port(3306) do
    it { should be_listening }
end

# ---------------------------------------------------------
# curlでHTTPアクセスして200 OKが返ってくること
# ---------------------------------------------------------
describe command('curl http://127.0.0.1:#{listen_port}/_plugin/head/ -o /dev/null -w "%{http_code}\n" -s') do
    its(:stdout) { should match /^200$/ }
end

# ---------------------------------------------------------
# serviceが起動していること
# ---------------------------------------------------------
services = ['mysqld',
            'nginx'
            ]

services.each do |service|
    describe service(service) do
        it { should be_running }
    end
end

describe command(' ps aux | grep unicorn') do
    its(:exit_status){ should eq 0 }
end

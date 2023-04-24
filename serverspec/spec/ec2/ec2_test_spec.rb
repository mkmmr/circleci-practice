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
            'mysql-server',
            'mysql-devel',
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
describe command('/home/ec2-user/.rbenv/shims/ruby --version') do
    its(:stdout) { should match(/#{Regexp.escape('ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-linux]')}/) }
end

describe command('rails -v') do
    its(:stdout) { should match /Rails 7\.0\.4/ }
end

describe command('bundler -v') do
    it { should be_installed.by('gem').with_version('2.3.14') }
end

# ---------------------------------------------------------
# アプリのディレクトリが指定した場所に存在すること
# ---------------------------------------------------------
describe file('#{app_dir}') do
    it { should be_directory }
end

# ---------------------------------------------------------
# nginxのconfファイルが存在すること
# ---------------------------------------------------------
describe file('/etc/nginx/conf.d/raisetech-live8-sample-app.conf') do
    it { should be_file }
end

# ---------------------------------------------------------
# config/environments/development.rbにALBエンドポイントが記載されていること
# ---------------------------------------------------------
describe file('#{app_dir}/config/environments/development.rb') do
    its(:content) { should match "
<source>
    config.active_storage.service = :amazon
    ap-northeast-1.elb.amazonaws.com
</source>" }
end

# ---------------------------------------------------------
# config/unicorn.rbに指定した文字列が存在すること
# ---------------------------------------------------------
describe file('#{app_dir}/config/unicorn.rb') do
    its(:content) { should match "
<source>
    listen '{{ app_dir }}/unicorn.sock'
    pid    '{{ app_dir }}/unicorn.pid'
</source>" }
end

# ---------------------------------------------------------
# config/storage.ymlに指定した文字列が存在すること
# ---------------------------------------------------------
describe file('#{app_dir}/config/storage.yml') do
    its(:content) { should match "
<source>
    <%= ENV['S3_IAM_ACCESS_KEY'] %>
    <%= ENV['S3_IAM_SECRET_ACCESS_KEY'] %>
    <%= ENV['S3_BUCKET_NAME'] %>
</source>" }
end

# ---------------------------------------------------------
# portが正しくリッスンしていること
# ---------------------------------------------------------
describe port(80) do
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
services = ['mysql',
            'nginx',
            'unicorn',
            ]

services.each do |service|
    describe service(service) do
        it { should be_running }
    end
end

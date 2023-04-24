require 'spec_helper'

listen_port = 80

describe package('nginx') do
    it { should be_installed }
end

describe port(listen_port) do
    it { should be_listening }
end

describe command('curl http://127.0.0.1:#{listen_port}/_plugin/head/ -o /dev/null -w "%{http_code}\n" -s') do
    its(:stdout) { should match /^200$/ }
end

describe command('/home/ec2-user/.rbenv/shims/ruby --version') do
    its(:stdout) { should match(/#{Regexp.escape('ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-linux]')}/) }
end

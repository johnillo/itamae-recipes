require 'spec_helper'

# TODO:
# Update this rake spec to your needs

# ----------------------------------------------------------------
# system
# ----------------------------------------------------------------

describe service('sshd') do
  it { should be_enabled }
  it { should be_running }
end
describe port(22) do
  it { should be_listening }
end

describe command('date | grep UTC') do
  its(:exit_status) { should eq 0 }
end

describe package('mlocate') do
  it { should be_installed }
end

describe package('vim') do
  it { should be_installed }
end

# ----------------------------------------------------------------
# docker
# ----------------------------------------------------------------

describe package('docker.io') do
  it { should be_installed }
end

describe command('docker-compose -v') do
  its(:exit_status) { should eq 0 }
end

# docker host ip
describe command('ip route show | grep docker0 | awk "{print \$9}"') do
  its(:stdout) { should match /172\.17.+/ }
end

# ----------------------------------------------------------------
# apache
# ----------------------------------------------------------------

describe package('apache2') do
  it { should be_installed }
end

describe service('apache2') do
  it { should be_enabled }
  it { should be_running }
end

# port 80 is open
describe port(80) do
  it { should be_listening }
end

# port 443 is open
# describe port(443) do
#   it { should be_listening }
# end

describe file('/etc/apache2/sites-available/myapp.local.conf') do
  it { should be_file }
end

# waf is working
describe command('curl -H "User-Agent: Nikto" myapp.local') do
  its(:stdout) { should match /403 Forbidden/ }
end

# ----------------------------------------------------------------
# mysql
# ----------------------------------------------------------------

describe package('mysql-server') do
  it { should be_installed }
end

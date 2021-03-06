require 'serverspec'
require 'net/ssh'
require 'tempfile'

set :backend, :ssh

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "Highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end

host = ENV['TARGET_HOST']

if host == 'myapp-local'
  # config for vagrant host
  config = Tempfile.new('', Dir.tmpdir)
  config.write(`vagrant ssh-config #{host}`)
  config.close
  options = Net::SSH::Config.for(host, [config])
else
  # config for regular host
  options = Net::SSH::Config.for(host)
end

options[:user] ||= Etc.getlogin

set :host,        options[:host_name] || host
set :ssh_options, options

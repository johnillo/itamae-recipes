nodename = node['nodename']
mods_available = node['apache']['mods_available']
sites_available = node['apache']['sites_available']
mod_security = node['apache']['mod_security']
sec_rule_engine = node['apache']['mod_security'] ? 'SecRuleEngine On' : 'SecRuleEngine DetectionOnly'

sites_dir = '/etc/apache2/sites-available'
mods_dir = '/etc/apache2/mods-available'
sites_enabled_dir = '/etc/apache2/sites-enabled'
install_packages = [
  'apache2',
  'libapache2-mod-security2'
]
enabled_modules = [
  'proxy',
  'proxy_http',
  'headers'
]

install_packages.each do |p|
  package p do
    action :install
  end
end

enabled_modules.each do |m|
  execute "enable apache module: #{m}" do
    user 'root'
    command <<-EOF
      a2enmod #{m}
    EOF
    notifies :restart, 'service[apache2]', :delay
  end
end

execute 'remove default config files' do
  user 'root'
  command <<-EOF
    rm -f #{sites_dir}/*default*.conf
    rm -f #{sites_enabled_dir}/*default*.conf
  EOF
  notifies :restart, 'service[apache2]', :delay
  only_if "test -e #{sites_dir}/000-default.conf"
end

sites_available.each do |site|
  template "copy #{site} to sites-available" do
    path "#{sites_dir}/#{site}.conf"
    source "templates/#{nodename}#{sites_dir}/#{site}.conf.erb"
    user 'root'
    mode '644'
    owner 'root'
    group 'root'
    variables(
      proxypass: node['apache']['proxypass'],
      serveradmin: node['apache']['serveradmin'],
      servername: nodename,
    )
    notifies :restart, 'service[apache2]', :delay
  end
  execute "enable site: #{site}" do
    user 'root'
    command <<-EOF
      a2ensite #{site}
    EOF
    notifies :restart, 'service[apache2]', :delay
  end
end

execute 'configure modsecurity (WAF)' do
  user 'root'
  command <<-EOF
    cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
    sed -i -e 's/^SecRuleEngine.*/#{sec_rule_engine}/i' /etc/modsecurity/modsecurity.conf
    rm -rf /usr/share/modsecurity-crs
    git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs
    cp /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
  EOF
  notifies :restart, 'service[apache2]', :delay
end

mods_available.each do |mod|
  remote_file "copy #{mod} to mods-available" do
    path "#{mods_dir}/#{mod}.conf"
    source "files/#{nodename}#{mods_dir}/#{mod}.conf"
    user 'root'
    mode '644'
    owner 'root'
    group 'root'
    notifies :restart, 'service[apache2]', :delay
  end
  execute "enable mod: #{mod}" do
    user 'root'
    command <<-EOF
      a2enmod #{mod}
    EOF
    notifies :restart, 'service[apache2]', :delay
  end
end

service 'apache2' do
  action [:enable, :start]
end

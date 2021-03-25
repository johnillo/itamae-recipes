nodename = node["nodename"]

package 'mysql-server' do
  action :install
  not_if 'test $(which mysql)'
end

directory '/var/lib/mysql/work/' do
  action :create
end

template 'create initialiation SQL' do
  path '/var/lib/mysql/work/init.sql'
  source "templates/#{nodename}/var/lib/mysql/work/init.sql.erb"
  user 'root'
  mode '644'
  owner 'root'
  group 'root'
  variables(
    user: node['mysql']['user'],
    password: node['mysql']['password'],
    db_name: node['mysql']['db_name'],
    testdb_name: node['mysql']['testdb_name']
  )
  notifies :restart, 'service[mysql]', :delay
  not_if 'test -e /var/lib/mysql/work/init.sql'
end

if node['mysql']['address_binding']
  execute 'set address binding' do
    command <<-EOF
      sed -i 's/^#bind-address/bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
    EOF
    notifies :restart, 'service[mysql]', :delay
  end
else
  execute 'set address binding' do
    command <<-EOF
      sed -i 's/^bind-address/#bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
    EOF
    notifies :restart, 'service[mysql]', :delay
  end
end

execute 'initialize databases' do
  user 'root'
  command <<-EOF
    mysql < /var/lib/mysql/work/init.sql
    touch /var/log/initdb
  EOF
  not_if 'test -e /var/log/initdb'
end

service 'mysql' do
  action [:enable, :start]
end

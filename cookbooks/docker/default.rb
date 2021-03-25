compose_version = node["docker"]["compose_version"]
docker_user = node["docker"]["user"]
docker_workdir = node["docker"]["workdir"]

package 'docker.io' do
  action :install
  not_if "test $(which docker)"
end

execute 'add user to docker group' do
  user "root"
  command <<-EOH
    usermod -a -G docker #{docker_user}
  EOH
  not_if "cat /etc/group | grep '^docker' | grep #{docker_user}"
end

execute 'install docker-compose' do
  user "root"
  command <<-EOH
    curl -L https://github.com/docker/compose/releases/download/#{compose_version}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  EOH
  not_if "test $(which /usr/local/bin/docker-compose)"
end

execute 'add docker to PATH' do
  user "root"
  command <<-EOH
    echo "export DOCKER_HOME=#{docker_workdir}" >> /etc/environment
    echo "export PATH=$PATH:$DOCKER_HOME" >> /etc/environment
  EOH
  not_if "cat /etc/environment | grep DOCKER_HOME"
end

service 'docker' do
  action [:enable, :start]
end

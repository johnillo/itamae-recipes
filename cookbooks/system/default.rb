locale = node["system"]["locale"]
timezone = node["system"]["timezone"]

execute 'set locale' do
  user "root"
  command <<-EOH
    locale-gen #{locale}
    update-locale LANG=#{locale}
    echo "export LANG=#{locale}" >> /etc/environment
    echo "export LC_ALL=#{locale}" >> /etc/environment
    echo "export PATH=$PATH" >> /etc/environment
  EOH
  not_if "cat /etc/environment | grep LANG"
end

execute 'update timezone' do
  user "root"
  command <<-EOL
    rm /etc/localtime
    ln -s /usr/share/zoneinfo/#{timezone} /etc/localtime
  EOL
end


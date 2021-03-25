options = node["package_update"]["yum_options"]

case node[:platform]
  when "ubuntu"
    execute 'apt update' do
      user "root"
      command 'apt update -y'
    end
    execute 'apt full-upgrade' do
      user "root"
      command 'apt full-upgrade -y'
    end

  when "centos", "redhat", "amazon"
    execute "update yum repo" do
      user "root"
      command "yum -y update #{options}"
    end
end

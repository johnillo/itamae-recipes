WORK_DIR = '/var/www/html/myapp'

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64" # 18.04

  # do not auto-update box if using vbguest
  if Object.const_defined? 'VagrantVbguest'
    config.vbguest.auto_update = false
    config.vm.box_check_update = false
  end

  # sync with nfs (faster than default but doesn't work on Windows)
  config.vm.synced_folder ".", WORK_DIR, type: "nfs", mount_options: ['actimeo=2']

  # setup local private network (required for nfs)
  config.vm.network :private_network, ip:"192.168.69.69"

  # foward port if in case dev wants to do test on a network pc
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # apply hostname (will prompt for password)
  config.vm.define "myapp-local"
  config.vm.hostname = "myapp.local"

  # adjust resources
  config.vm.provider "virtualbox" do |v|
    v.gui = false
    v.cpus = 2
    v.memory = 1024 # 1gb
  end

  # default to project directory in vm on vagrant ssh
  config.ssh.extra_args = ["-t", "cd #{WORK_DIR}; bash --login"]
end

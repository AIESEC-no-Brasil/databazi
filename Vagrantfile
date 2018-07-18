# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  # Required for NFS to work, pick any local IP
  config.vm.network :private_network, ip: '192.168.50.50'
  # Use NFS for shared folders for better performance
  config.vm.synced_folder '.', '/vagrant', nfs: true

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  config.vm.network "forwarded_port", guest: 3000, host: 3000

  config.vm.provision "shell", inline: <<-SHELL
    echo "cd /vagrant/" >> /home/vagrant/.bashrc
    sudo apt-get update

    sudo dd if=/dev/zero of=/swap bs=1M count=1024
    sudo mkswap /swap
    sudo swapon /swap

    locale-gen en_US en_US.UTF-8 pt_BR.UTF-8
    dpkg-reconfigure locales

    sudo apt-get install -y git
    sudo apt-get install -y build-essential
    sudo apt-get install -y postgresql postgresql-contrib postgresql-server-dev-9.3 libpq-dev
    sudo apt-get install -y nodejs

    sudo -u postgres psql -c"CREATE ROLE vagrant WITH LOGIN CREATEDB SUPERUSER PASSWORD 'vagrant'"

    sudo apt-get install -y curl
  SHELL

  config.vm.provision :shell, path: "install-rvm.sh", args: "stable", privileged: false
  config.vm.provision :shell, path: "install-ruby.sh", args: "2.5.1", privileged: false
end

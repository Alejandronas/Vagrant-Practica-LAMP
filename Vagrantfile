# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "debian/bookworm64"

  # --------------------------------------------------------------------------
  # Web Server (Apache + PHP)
  # --------------------------------------------------------------------------
  config.vm.define "web" do |web|
    # Hostname for the web server VM
    web.vm.hostname = "AlejandroApache"

    # Create a private network so the web server can communicate with the DB server
    web.vm.network "private_network", ip: "192.168.56.10"

    # Create a forwarded port mapping to access Apache from the host
    web.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true

    # Provisioning with an external shell script
    web.vm.provision "shell", path: "provision-web.sh"

    # Provider-specific configuration for VirtualBox
    web.vm.provider "virtualbox" do |vb|
      vb.name = "AlejandroApache"
      vb.memory = 1024
      vb.cpus = 1
    end
  end

  # --------------------------------------------------------------------------
  # Database Server (MySQL/MariaDB)
  # --------------------------------------------------------------------------
  config.vm.define "db" do |db|
  db.vm.hostname = "AlejandroMysql"
  
  # Red privada con la web
  db.vm.network "private_network", ip: "192.168.56.11"

  # Reenvío de puerto SSH para poder usar vagrant ssh desde host
  db.vm.network "forwarded_port", guest: 22, host: 2222, auto_correct: true

  db.vm.provision "shell", path: "provision-db.sh"

  db.vm.provider "virtualbox" do |vb|
    vb.memory = 512
    vb.cpus = 1
  end
end

  # --------------------------------------------------------------------------
  # Shared folders and general configuration
  # --------------------------------------------------------------------------

  # Share the current folder with the VM (useful to access your files inside)
  config.vm.synced_folder ".", "/vagrant", disabled: false

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end

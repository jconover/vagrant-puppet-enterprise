# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "richburroughs/centos65"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "https://dl.dropboxusercontent.com/s/no7mqxvxx211dgb/centos65.box?dl=1"
  config.vm.box_url = "richburroughs/centos65"

  # Comment out this next line or set the variable to false if you don't want
  # the master to be set up  automatically to do dynamic environments

  provision_environments = true

  # Master config

  config.vm.define "master", primary: true do |master|
    master.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.name = "vagrant-pe-master"
    end
    master.vm.network :private_network, ip: "192.168.77.2"
    master.vm.network "forwarded_port", guest: 443, host: 12003, protocol: 'tcp'
    master.vm.hostname = "master"
    master.vm.provision "shell", path: "bin/provision.sh"
    master.vm.provision "shell", path: "bin/pe_master_provision.sh"
    master.vm.provision "puppet", manifest_file: "default.pp"
      if provision_environments
        master.vm.provision "puppet", manifest_file: "master_provision_environments.pp"
      end
  end

  # Agent config

  config.vm.define "agent1" do |agent1|
    agent1.vm.provider "virtualbox" do |v|
      v.name = "vagrant-pe-agent1"
    end
    agent1.vm.network :private_network, ip: "192.168.77.3"
    agent1.vm.hostname = "agent1"
    agent1.vm.provision "shell", path: "bin/provision.sh"
    agent1.vm.provision "shell", path: "bin/pe_agent_provision.sh"
    agent1.vm.provision "puppet", manifest_file: "default.pp"
      if provision_environments
        agent1.vm.provision "puppet", manifest_file: "agent_provision_environments.pp"
      end
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network :forwarded_port, guest: 80, host: 8080

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end
end

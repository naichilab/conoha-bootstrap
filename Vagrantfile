# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos65"
  config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"

  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder "/Users/hu/vagrant-railstutorial", "/home/vagrant/railstutorial"

  config.omnibus.chef_version = :latest
end

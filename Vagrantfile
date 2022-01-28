# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
ENV["VAGRANT_EXPERIMENTAL"] = "disks"

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox
  config.vm.define  "mgs"
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01" # CentOS release 7.8.2003
  config.vm.hostname = "mgs"
  config.vm.network "private_network", ip: "192.168.10.10"
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.disk :disk, size: "10GB", name: "extra_disk_lustre"
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
ENV["VAGRANT_EXPERIMENTAL"] = "disks"

# box_version 2004.01 => CentOS release 7.8.2003

$create_repo_e2fsprogs = <<-SCRIPT
cat > /etc/yum.repos.d/e2fsprogs-wc.repo <<EOF
[e2fsprogs-wc]
name=e2fsprogs-wc
baseurl=https://downloads.whamcloud.com/public/e2fsprogs/1.44.3.wc1/el7
gpgcheck=0
enabled=1
EOF
SCRIPT

$create_repo_lustre_server = <<-SCRIPT
cat > /etc/yum.repos.d/lustre-server.repo <<EOF
[lustre-server]
name=lustre-server
baseurl=https://downloads.whamcloud.com/public/lustre/lustre-2.12.5/el7.8.2003/server
gpgcheck=0
enabled=1
EOF
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox
  config.vm.define  "mgs"
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"
  config.vm.hostname = "mgs"
  config.vm.network "private_network", ip: "192.168.10.10"
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.disk :disk, size: "10GB", name: "disk_for_lustre"
  config.vm.provision "shell", name: "repo_e2fsprogs", inline: $create_repo_e2fsprogs
  config.vm.provision "shell", name: "repo_lustre_server", inline: $create_repo_lustre_server
  config.vm.provision "shell" do |s|
    s.name = "pkg_inst"
    s.privileged = true
    s.inline = %q(
      yum install -y e2fsprogs
      yum install -y epel-release
      yum install -y kmod-lustre
      yum install -y kmod-lustre-osd-ldiskfs
      yum install -y lustre-osd-ldiskfs-mount
      yum install -y lustre
    )
    s.reboot = true
  end
end

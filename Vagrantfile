# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
ENV["VAGRANT_EXPERIMENTAL"] = "disks"

hosts = %q(
127.0.0.1     localhost localhost.localdomain localhost4 localhost4.localdomain4
::1           localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.10.10 mxs
192.168.10.11 oss
)

$create_file_hosts = <<-SCRIPT
echo "#{hosts}" > /etc/hosts
SCRIPT

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

$create_repo_lustre_client = <<-SCRIPT
cat > /etc/yum.repos.d/lustre-client.repo <<EOF
[lustre-client]
name=lustre-client
baseurl=https://downloads.whamcloud.com/public/lustre/lustre-2.12.5/el7.8.2003/client
gpgcheck=0
enabled=1
EOF
SCRIPT

$install_packages_server_mds = <<-SCRIPT
yum install -y e2fsprogs
yum install -y epel-release
yum install -y kmod-lustre
yum install -y kmod-lustre-osd-ldiskfs
yum install -y lustre-osd-ldiskfs-mount
yum install -y lustre
SCRIPT

$install_packages_client = <<-SCRIPT
yum install -y kmod-lustre-client
yum install -y lustre-client
SCRIPT

$configure_lustre_server_lnet = <<-SCRIPT
# Should be set before lnet module is loaded.
echo "options lnet networks=tcp0(eth1)" > /etc/modprobe.d/lnet.conf
SCRIPT

$configure_lustre_server_mgs_mds = <<-SCRIPT
mkdir /mnt/mdt
mkfs.lustre --backfstype=ldiskfs --fsname=phoenix --mgs --mdt --index=0 /dev/sdb
# Mounting Lustre loads lnet module implicitly.
mount -t lustre /dev/sdb /mnt/mdt
SCRIPT

$configure_lustre_server_oss = <<-SCRIPT
mkfs.lustre --ost --fsname=phoenix --mgsnode=mxs@tcp0 --index=1 /dev/sdb
mkfs.lustre --ost --fsname=phoenix --mgsnode=mxs@tcp0 --index=2 /dev/sdc

mkdir /mnt/ost1
mkdir /mnt/ost2

# Mounting OSTs loads lnet module implicitly.
mount.lustre /dev/sdb /mnt/ost1
mount.lustre /dev/sdc /mnt/ost2
SCRIPT

$configure_lustre_client = <<-SCRIPT
mkdir /lustre
# Mounting Lustre endpoint loads lnet and lustre module implicitly.
mount -t lustre mxs@tcp0:/phoenix /lustre
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox
  config.vm.box = "centos/7"
  # box_version 2004.01 => CentOS release 7.8.2003
  config.vm.box_version = "2004.01"
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provision "shell", name: "create_file_hosts", inline: $create_file_hosts

  config.vm.define  "mxs" do |mxs|
    mxs.vm.hostname = "mxs"
    mxs.vm.network "private_network", ip: "192.168.10.10"
    mxs.vm.disk :disk, size: "10GB", name: "disk_for_lustre"
    mxs.vm.provision "shell", name: "create_repo_e2fsprogs", inline: $create_repo_e2fsprogs
    mxs.vm.provision "shell", name: "create_repo_lustre_server", inline: $create_repo_lustre_server
    mxs.vm.provision "shell", name: "install_packages", inline: $install_packages_server_mds, reboot: true
    mxs.vm.provision "shell", name: "configure_lnet", inline: $configure_lustre_server_lnet
    mxs.vm.provision "shell", name: "configure_mgs_mds", inline: $configure_lustre_server_mgs_mds
  end

  config.vm.define  "oss" do |oss|
    oss.vm.hostname = "oss"
    oss.vm.network "private_network", ip: "192.168.10.11"
    oss.vm.disk :disk, size: "10GB", name: "disk_for_lustre_ost_1"
    oss.vm.disk :disk, size: "10GB", name: "disk_for_lustre_ost_2"
    oss.vm.provision "shell", name: "create_repo_e2fsprogs", inline: $create_repo_e2fsprogs
    oss.vm.provision "shell", name: "create_repo_lustre_server", inline: $create_repo_lustre_server
    oss.vm.provision "shell", name: "install_packages", inline: $install_packages_server_mds, reboot: true
    oss.vm.provision "shell", name: "configure_lnet", inline: $configure_lustre_server_lnet
    oss.vm.provision "shell", name: "configure_oss", inline: $configure_lustre_server_oss
  end

  config.vm.define  "client" do |client|
    client.vm.hostname = "client"
    client.vm.network "private_network", ip: "192.168.10.12"
    client.vm.provision "shell", name: "create_repo_lustre_client", inline: $create_repo_lustre_client
    client.vm.provision "shell", name: "install_packages", inline: $install_packages_client
    client.vm.provision "shell", name: "config", inline: $configure_lustre_client
  end
end

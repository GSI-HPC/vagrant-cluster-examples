# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
ENV["VAGRANT_EXPERIMENTAL"] = "disks"

hosts = %q(
127.0.0.1     localhost localhost.localdomain localhost4 localhost4.localdomain4
::1           localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.10.10 mxs
192.168.10.20 oss
192.168.10.30 client
)

$create_file_hosts = <<-SCRIPT
echo "#{hosts}" > /etc/hosts
SCRIPT

$create_repo_e2fsprogs = <<-SCRIPT
cat > /etc/yum.repos.d/e2fsprogs-wc.repo <<EOF
[e2fsprogs-wc]
name=e2fsprogs-wc
baseurl=https://downloads.whamcloud.com/public/e2fsprogs/latest/el7
gpgcheck=0
enabled=0
EOF
SCRIPT

$create_repo_lustre_server = <<-SCRIPT
cat > /etc/yum.repos.d/lustre-server.repo <<EOF
[lustre-server]
name=lustre-server
baseurl=https://downloads.whamcloud.com/public/lustre/lustre-2.14.0/el8.3.2011/server
gpgcheck=0
enabled=0
EOF
SCRIPT

$create_repo_lustre_client = <<-SCRIPT
cat > /etc/yum.repos.d/lustre-client.repo <<EOF
[lustre-client]
name=lustre-client
baseurl=https://downloads.whamcloud.com/public/lustre/lustre-2.14.0/el8.3.2011/client
gpgcheck=0
enabled=0
EOF
SCRIPT

$install_packages_e2fsprogs = <<-SCRIPT
yum install -y --nogpgcheck --disablerepo=* --enablerepo=e2fsprogs-wc e2fsprogs
SCRIPT

$install_packages_dkms = <<-SCRIPT
yum list installed | grep -E "^dkms.*3\.0\.3.*"
exitCode=$?
if [ $exitCode -ne 0 ]; then
    yum install -y https://download-ib01.fedoraproject.org/pub/epel/next/8/Everything/aarch64/Packages/d/dkms-3.0.3-1.el8.next.noarch.rpm
else
    echo "Skipping installation of package dkms, since it is already installed."
fi
SCRIPT

$remove_old_packages_kernel = <<-SCRIPT
VER="4.18.0-277.el8"
yum remove -y kernel-$VER \
kernel-core-$VER \
kernel-tools-$VER \
kernel-tools-lib-$VER
SCRIPT

$install_packages_kernel_patched = <<-SCRIPT
VER="4.18.0-240.1.1.el8_lustre"
yum --nogpgcheck --disablerepo=* --enablerepo=lustre-server install -y \
kernel-$VER \
kernel-devel-$VER \
kernel-headers-$VER
SCRIPT

$install_packages_server_ldiskfs = <<-SCRIPT
yum --nogpgcheck --enablerepo=lustre-server install -y \
lustre-osd-ldiskfs-mount \
lustre
SCRIPT

$install_packages_server_zfs = <<-SCRIPT
yum --nogpgcheck --enablerepo=lustre-server install -y \
lustre-osd-zfs-mount \
lustre
SCRIPT

$install_packages_client = <<-SCRIPT
yum install --enablerepo=powertools libyaml-devel
yum --nogpgcheck --enablerepo=lustre-client install -y \
lustre-client
SCRIPT

$disable_selinux = <<-SCRIPT
echo "SELINUX=disabled" > /etc/selinux/config
SCRIPT

$configure_lnet = <<-SCRIPT
# Should be set before lnet module is loaded.
echo "options lnet networks=tcp0(eth1)" > /etc/modprobe.d/lnet.conf
SCRIPT

$configure_lustre_server_mgs_mds = <<-SCRIPT
modprobe -v lnet
modprobe -v lustre
mkdir /mnt/mdt
mkfs.lustre --backfstype=ldiskfs --fsname=phoenix --mgs --mdt --index=0 /dev/sdb
mount -t lustre /dev/sdb /mnt/mdt
SCRIPT

$configure_lustre_server_oss_zfs = <<-SCRIPT
modprobe -v lnet
modprobe -v lustre
modprobe -v zfs
zpool create ostpool0 /dev/sdb
zpool create ostpool1 /dev/sdc
mkfs.lustre --backfstype=zfs --ost --fsname phoenix --index 0 --mgsnode mxs@tcp0 ostpool0/ost0
mkfs.lustre --backfstype=zfs --ost --fsname phoenix --index 1 --mgsnode mxs@tcp0 ostpool1/ost1
mkdir -p /lustre/phoenix/ost0
mkdir -p /lustre/phoenix/ost1
mount -t lustre ostpool0/ost0 /lustre/phoenix/ost0
mount -t lustre ostpool1/ost1 /lustre/phoenix/ost1
SCRIPT

$configure_lustre_client = <<-SCRIPT
mkdir /lustre
mount -t lustre mxs@tcp0:/phoenix /lustre
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 2
  end
  config.vm.box = "centos/stream8"
  config.vm.box_version = "20210210.0"
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provision "shell", name: "create_file_hosts", inline: $create_file_hosts

  config.vm.define  "mxs" do |mxs|
    mxs.vm.hostname = "mxs"
    mxs.vm.network "private_network", ip: "192.168.10.10"
    mxs.vm.disk :disk, size: "10GB", name: "disk_for_lustre"
    mxs.vm.provision "shell", name: "create_repo_e2fsprogs", inline: $create_repo_e2fsprogs
    mxs.vm.provision "shell", name: "create_repo_lustre_server", inline: $create_repo_lustre_server
    mxs.vm.provision "shell", name: "install_perl", inline: "yum install -y perl"
    mxs.vm.provision "shell", name: "install_packages_kernel_patched", inline: $install_packages_kernel_patched, reboot: true
    mxs.vm.provision "shell", name: "remove_old_packages_kernel", inline: $remove_old_packages_kernel
    mxs.vm.provision "shell", name: "install_packages_e2fsprogs", inline: $install_packages_e2fsprogs
    mxs.vm.provision "shell", name: "install_packages_ldiskfs", inline: $install_packages_server_ldiskfs
    mxs.vm.provision "shell", name: "disable_selinux", inline: $disable_selinux, reboot: true
    mxs.vm.provision "shell", name: "configure_lnet", inline: $configure_lnet
    mxs.vm.provision "shell", name: "configure_mgs_mds", inline: $configure_lustre_server_mgs_mds
  end

  config.vm.define  "oss" do |oss|
    oss.vm.hostname = "oss"
    oss.vm.network "private_network", ip: "192.168.10.20"
    oss.vm.disk :disk, size: "10GB", name: "disk_for_lustre_ost_1"
    oss.vm.disk :disk, size: "10GB", name: "disk_for_lustre_ost_2"
    oss.vm.provision "shell", name: "create_repo_e2fsprogs", inline: $create_repo_e2fsprogs
    oss.vm.provision "shell", name: "create_repo_lustre_server", inline: $create_repo_lustre_server
    ##oss.vm.provision "shell", name: "install_perl", inline: "yum install -y perl"
    ##oss.vm.provision "shell", name: "install_packages_kernel_patched", inline: $install_packages_kernel_patched, reboot: true
    ##oss.vm.provision "shell", name: "remove_old_packages_kernel", inline: $remove_old_packages_kernel
    ##oss.vm.provision "shell", name: "install_packages_e2fsprogs", inline: $install_packages_e2fsprogs
    ##oss.vm.provision "shell", name: "install_packages_zfs", inline: $install_packages_server_zfs
    ##oss.vm.provision "shell", name: "disable_selinux", inline: $disable_selinux, reboot: true
    ##oss.vm.provision "shell", name: "configure_lnet", inline: $configure_lnet
    ##oss.vm.provision "shell", name: "configure_oss", inline: $configure_lustre_server_oss_zfs
  end

  config.vm.define  "client" do |client|
    client.vm.hostname = "client"
    client.vm.network "private_network", ip: "192.168.10.30"
    client.vm.provision "shell", name: "create_repo_lustre_client", inline: $create_repo_lustre_client
    client.vm.provision "shell", name: "create_repo_lustre_server", inline: $create_repo_lustre_server
    ##client.vm.provision "shell", name: "install_perl", inline: "yum install -y perl"
    ##client.vm.provision "shell", name: "install_packages_kernel_patched", inline: $install_packages_kernel_patched, reboot: true
    ##client.vm.provision "shell", name: "install_packages_dkms", inline: $install_packages_dkms
    ##client.vm.provision "shell", name: "install_packages_client", inline: $install_packages_client
    ##client.vm.provision "shell", name: "configure_lnet", inline: $configure_lnet
    ##client.vm.provision "shell", name: "configure_client", inline: $configure_lustre_client
  end
end

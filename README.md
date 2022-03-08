# Lustre Installation with Vagrant

Check different installation examples in the listed directories.

## Prerequisites

* [Vagrant](https://www.vagrantup.com/)     - Version tested: 2.2.14
* [VirtualBox](https://www.virtualbox.org/) - Version tested: 6.1.30

## Lustre

### Support Matrix

https://wiki.whamcloud.com/display/PUB/Lustre+Support+Matrix

### Changelog

For checking kernel version compatible to a Lustre version.  

https://git.whamcloud.com/?p=fs/lustre-release.git;a=blob;f=lustre/ChangeLog

### Installation

https://wiki.lustre.org/Installing_the_Lustre_Software
https://wiki.lustre.org/Creating_Lustre_Object_Storage_Services_(OSS)

### Command for Checking Status

#### MGS

Show live parameter:  
`lctl get_param mgs.MGS.live.*`

#### All Nodes

Show all devices:  
`lctl dl`

### Additional CentOS Repositories

Example for CentOS 7.8 with kernel 3.10.0-1127.19.1:  

```
$create_repo_iij_ad_jp_updates = <<-SCRIPT
cat > /etc/yum.repos.d/iij_ad_jp_updates.repo <<EOF
[iij-ad-jp-updates]
name=iij-ad-jp-updates
baseurl=http://ftp.iij.ad.jp/pub/linux/centos-vault/centos/7.8.2003/updates/x86_64
gpgcheck=0
enabled=0
EOF
SCRIPT

$install_packages_kernel = <<-SCRIPT
VER="3.10.0-1127.19.1.el7"
yum install --nogpgcheck --disablerepo=* --enablerepo=iij-ad-jp-updates -y \
kernel-$VER \
kernel-devel-$VER \
kernel-headers-$VER \
kernel-abi-whitelists-$VER \
kernel-tools-$VER \
kernel-tools-libs-$VER \
kernel-tools-libs-devel-$VER
SCRIPT
```

# Lustre Installation with Vagrant

Check different installation examples in the listed directories.

## Prerequisites

* [Vagrant](https://www.vagrantup.com/)     - Version tested: 2.2.14
  * `vagrant plugin install vagrant-scp`
* [VirtualBox](https://www.virtualbox.org/) - Version tested: 6.1.30

## Lustre

### Support Matrix

https://wiki.whamcloud.com/display/PUB/Lustre+Support+Matrix

### Changelog

For checking kernel version compatible to a Lustre version.  

https://git.whamcloud.com/?p=fs/lustre-release.git;a=blob;f=lustre/ChangeLog

### Installation

https://wiki.lustre.org/Installing\_the\_Lustre\_Software
https://wiki.lustre.org/Creating\_Lustre\_Object\_Storage\_Services_(OSS)

### Command for Checking Status

#### MGS

Show live parameter:  
`lctl get_param mgs.MGS.live.*`

#### All Nodes

Show all devices:  
`lctl dl`

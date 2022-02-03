# Lustre Installation with Vagrant

Lustre version: 2.12.5  
CentOS release: el7.8.2003

## Prerequisites

* vagrant
* virtualbox

## Vagrant

`vagrant box add centos/7`

`vagrant up`

## Lustre

### Support Matrix

https://wiki.whamcloud.com/display/PUB/Lustre+Support+Matrix

### Installation

https://wiki.lustre.org/Installing_the_Lustre_Software

### Command for Checking Status

#### MGS

Show live parameter:  
`lctl get_param mgs.MGS.live.*`

#### All Nodes

Show all devices:  
`lctl dl`

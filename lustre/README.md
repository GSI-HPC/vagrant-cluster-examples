# Lustre Installations

## Lustre

### Support Matrix

https://wiki.whamcloud.com/display/PUB/Lustre+Support+Matrix

### Changelog

For checking kernel version compatible to a Lustre version.  

https://git.whamcloud.com/?p=fs/lustre-release.git;a=blob;f=lustre/ChangeLog

### Documentation

#### Installation

https://wiki.lustre.org/Installing\_the\_Lustre\_Software
https://wiki.lustre.org/Creating\_Lustre\_Object\_Storage\_Services_(OSS)

### Command for Checking Status

#### MGS

Show live parameter:  
`lctl get_param mgs.MGS.live.*`

#### All Nodes

Show all devices:  
`lctl dl`


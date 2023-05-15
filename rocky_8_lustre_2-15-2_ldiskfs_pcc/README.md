# Lustre 2.15.2 with LDISKFS and PCC on Rocky Linux 8

## Starting the Cluster

Starting complete cluster:

```shell
./setup_cluster.sh
```

Components can be started separately:

1. `./start_mxs.sh`
1. `./start_oss.sh`
1. `./start_client.sh 1`
1. `./start_client.sh 2`

## Lustre Persistent Client Cache (PCC)

### Overview

* Posix `rm` command does not delete cached files on the PCC disk, unless files have been detached first.
* User must be aware of PCC commands e.g. `attach`, `detach` and `state` and the PCC workflow, otherwise...
  - PCC local disk keeps a copy of files, if files are not detached before accessed on Lustre by other clients.
  - Lustre disk space and inode quota check can be by passed and exceeded after detach!
  - IO processes can block on full local cache disk during write operation...

#### Full Local Disk

* During writing the IO process blocks on the client without any error.
  - Leaves data on disk...
* `lfs pcc attach` returns error, if disk is full "No space left on device".

#### Attach and Detach Operations

Attach and detach works per file.

##### Attach

* Saves file into PCC, if file exists already on a Lustre OST that it is moved into the PCC and removed from OST.
* Attach works on existing files only.
* Use `auto_attach` to directly create files in the PCC instead of writing data on OSTs first and attach afterwards.

##### Detach

Move cached file from PCC to Lustre OST.

### Testing

PCC configuration:

* `auto_attach` enabled
* Project id (pid) = 1000 (pid same as vagrant gid)
* gid = 1000 (vagrant)
* Project path = `/lustre/vagrant/scratch`

#### Basics with Single Client

Project quota info:

```
$ lfs quota -p 1000 /lustre -h
Disk quotas for prj 1000 (pid 1000):
     Filesystem    used   quota   limit   grace   files   quota   limit   grace
        /lustre      4k     90M    100M       -       1    1100    1500       -
```

lfs quota -g vagrant /lustre -h

```
lfs quota -g vagrant /lustre -h
Disk quotas for grp vagrant (gid 1000):
     Filesystem    used   quota   limit   grace   files   quota   limit   grace
        /lustre      8k      0k      0k       -       2       0       0       -
```

Creating file directly on Lustre OST:

```
$ dd if=/dev/urandom of=/lustre/vagrant/noscratch.tmp bs=10M count=10
104857600 bytes (105 MB, 100 MiB) copied, 5.39322 s, 19.4 MB/s
```

```
$ lfs quota -g vagrant /lustre -h
Disk quotas for grp vagrant (gid 1000):
     Filesystem    used   quota   limit   grace   files   quota   limit   grace
        /lustre  99.98M      0k      0k       -       3       0       0       -
```

```
$ lfs pcc state noscratch.tmp
file: noscratch.tmp, type: none
```

```
$ df -h
Filesystem                  Size  Used Avail Use% Mounted on
...
192.168.56.10@tcp:/phoenix   19G  103M   18G   1% /lustre
/dev/sdb1                   989M   52K  922M   1% /mnt/pcc
```

```
$ dd if=/dev/urandom of=/lustre/vagrant/scratch/0.tmp bs=10M count=20
209715200 bytes (210 MB, 200 MiB) copied, 11.9217 s, 17.6 MB/s
```

```
$ df -h
Filesystem                  Size  Used Avail Use% Mounted on
...
192.168.56.10@tcp:/phoenix   19G  103M   18G   1% /lustre
/dev/sdb1                   989M  201M  722M  22% /mnt/pcc
```

```
$ lfs pcc state /lustre/vagrant/scratch/0.tmp
file: /lustre/vagrant/scratch/0.tmp, type: readwrite, PCC file: /1000/000a/0000/0402/0000/0002/0000/0x200000402:0xa:0x0, user number: 0, flags: 0
```

```
$ lfs quota -g vagrant /lustre -h
Disk quotas for grp vagrant (gid 1000):
     Filesystem    used   quota   limit   grace   files   quota   limit   grace
        /lustre    100M      0k      0k       -       4       0       0       -
```

By passes quota!

```
$ lfs pcc detach /lustre/vagrant/scratch/0.tmp
```

```
$ df -h
Filesystem                  Size  Used Avail Use% Mounted on
...
192.168.56.10@tcp:/phoenix   19G  303M   18G   2% /lustre
/dev/sdb1                   989M  100K  922M   1% /mnt/pcc
```

Quota exceeded after detach

```
$ lfs quota -p 1000 /lustre -h
Disk quotas for prj 1000 (pid 1000):
     Filesystem    used   quota   limit   grace   files   quota   limit   grace
        /lustre    200M*    90M    100M       -       2    1100    1500       -
```

Can still write into the PCC

```
$ dd if=/dev/urandom of=/lustre/vagrant/scratch/1.tmp bs=10M count=50
524288000 bytes (524 MB, 500 MiB) copied, 28.6419 s, 18.3 MB/s
```

```
df -h
Filesystem                  Size  Used Avail Use% Mounted on
...
192.168.56.10@tcp:/phoenix   19G  303M   18G   2% /lustre
/dev/sdb1                   989M  501M  422M  55% /mnt/pcc
```

```
$ lfs pcc detach /lustre/vagrant/scratch/1.tmp
```

```
$ lfs quota -p 1000 /lustre -h
Disk quotas for prj 1000 (pid 1000):
     Filesystem    used   quota   limit   grace   files   quota   limit   grace
        /lustre    700M*    90M    100M       -       3    1100    1500       -
```

```
$ for i in {1..2000}; do touch /lustre/vagrant/scratch/$i.tmp; done
```

No detach required, I-Nodes are just created on Lustre

```
$ lfs quota -p 1000 /lustre -h
Disk quotas for prj 1000 (pid 1000):
     Filesystem    used   quota   limit   grace   files   quota   limit   grace
        /lustre  700.1M*    90M    100M       -    2002*   1100    1500       -
```

```
$ for i in {1..10000}; do touch /lustre/vagrant/scratch/$i-2.tmp; done
```

```
$ lfs quota -p 1000 /lustre -h
Disk quotas for prj 1000 (pid 1000):
     Filesystem    used   quota   limit   grace   files   quota   limit   grace
        /lustre  700.6M*    90M    100M       -   12002*   1100    1500       -
```

```
$ lfs df -i
UUID                      Inodes       IUsed       IFree IUse% Mounted on
phoenix-MDT0000_UUID     4194304       12280     4182024   1% /lustre[MDT:0]
phoenix-OST0001_UUID      655360         266      655094   1% /lustre[OST:1]
phoenix-OST0002_UUID      655360         265      655095   1% /lustre[OST:2]

filesystem_summary:      1322469       12280     1310189   1% /lustre
```

```
$ df -i
Filesystem                   Inodes IUsed    IFree IUse% Mounted on
...
192.168.56.10@tcp:/phoenix  1322464 12280  1310184    1% /lustre
/dev/sdb1                     65536 65536        0  100% /mnt/pcc
```

```
$ dd if=/dev/urandom of=/lustre/vagrant/scratch/full.tmp bs=10M count=1
dd: failed to open '/lustre/vagrant/scratch/full.tmp': No space left on device
```

#### Two Clients

\[vagrant@client1 ~\]
```
$ dd if=/dev/urandom of=/lustre/vagrant/scratch/0.tmp bs=10M count=10
104857600 bytes (105 MB, 100 MiB) copied, 5.23105 s, 20.0 MB/s

$ df -h
Filesystem                  Size  Used Avail Use% Mounted on
...
192.168.56.10@tcp:/phoenix   19G  2.5M   18G   1% /lustre
/dev/sdb1                   989M  101M  822M  11% /mnt/pcc
```

\[vagrant@client2 ~\]
```
$ ls -ltr /lustre/vagrant/scratch/
-rw-rw-r--. 1 vagrant vagrant 0 May 15 06:15 0.tmp

$ time head /lustre/vagrant/scratch/0.tmp
`>~rH:=a
...
real    0m1.039s

$ ls -ltrh /lustre/vagrant/scratch/
total 100M
-rw-rw-r--. 1 vagrant vagrant 100M May 15 06:15 0.tmp
```

\[vagrant@client1 ~\]
```
$ df -h
...
192.168.56.10@tcp:/phoenix   19G  103M   18G   1% /lustre
/dev/sdb1                   989M  101M  822M  11% /mnt/pcc

$ lfs pcc state /lustre/vagrant/scratch/0.tmp
file: /lustre/vagrant/scratch/0.tmp, type: none

$ rm /lustre/vagrant/scratch/0.tmp

$ df -h
Filesystem                  Size  Used Avail Use% Mounted on
...
192.168.56.10@tcp:/phoenix   19G  2.5M   18G   1% /lustre
/dev/sdb1                   989M  101M  822M  11% /mnt/pcc
```
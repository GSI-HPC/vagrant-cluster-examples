# Lustre 2.15.2 with LDISKFS and PCC on Rocky Linux 8

## Starting the Cluster

Starting complete cluster:

```shell
./setup_cluster.sh
```

Components can be started separately:

1. `./start_mxs.sh`
1. `./start_oss.sh`
1. `./start_client.sh`

In any case, for the different components the following messages should appear at the end of its section:

**MXS (MDS+MGS)**:

```
Lustre filesystem mounted on MXS
Successfully started MXS
```

**OSS**:

```
All OSTs mounted on OSS
Successfully started OSS
```

**client**:

```
Lustre filesystem mounted on client
Lustre filesystem information found on client
Successfully started client
```
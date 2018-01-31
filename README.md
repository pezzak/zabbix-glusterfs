zabbix-glusterfs
======
Templates and scripts for glusterfs-server and glusterfs-client

Tested on:
- Zabbix 3.2
- Glusterfs client/server 3.7.11

Add zabbix to /etc/sudoers:
```
zabbix ALL=(ALL) NOPASSWD:/usr/sbin/gluster
```

**WORK IN PROGRESS**

# Kubernetes the hard way - lxd

## Step 0 - Install lxd

Follow the [official documentation](https://linuxcontainers.org/lxd/getting-started-cli)
to install lxd for your platform.

**Optional**

Lxd provides a DNS server that automatically tracks container IPs under
`<container hostname>.lxd`. However, by default the DNS server is only available
within the containers. You can configure systemd to makes these DNS records
available on the host:

Create a file called `/etc/systemd/network/lxd.network`:
```
[Match]
Name=lxdbr0

[Network]
DNS=10.121.179.1
Domains=~lxd

[Address]
Address=10.121.179.1/24
Gateway=10.121.179.1
```

Enable the systemd network daemon:
```
sudo systemctl enable systemd-networkd
```

Restart your machine


## Step 1 - Provisioning Compute Resources

Use the provided script to create the lxd base image:
```
./script/create-base-image
```

And then launch the necessary containers:
```
./scripts/launch
```

This will create the following lxd nodes:
 - **load-balancer** - This will contain our HTTP loadbalancer that will forward
   traffic to cluster nodes.
 - **controller0** - The first member of our Kubernetes control plane cluster
 - **controller1** - The second member of our Kubernetes control plane cluster
 - **controller2** - The third member of our Kubernetes control plane cluster
 - **worker0** - The first worker node for running the workloads we want on Kubernetes
 - **worker1** - The second worker node for running the workloads we want on Kubernetes


## Step 2 - Provisioning the CA and Generating TLS Certificates
Install `cfssl` tools:
```
go get -u github.com/cloudflare/cfssl/cmd/cfssl
go get -u github.com/cloudflare/cfssl/cmd/cfssljson
```

Run the cert generation script:
```
./scripts/generate-certs
```
You should see several CA/client certs in the project dir

Upload the certs to the appropriate hosts:
```
./scripts/upload-certs
```

## Step 3 - Generating Kubernetes Configuration Files for Authentication
Run the config generation script:
```
./scripts/generate-kube-configs
```

Upload the config files to the appropriate hosts:
```
./scripts/upload-kube-configs
```

## Step 4 - Generating the Data Encryption Config and Key
Run the encryption config generation script:
```
./scripts/generate-encryption-config
```

Upload the config file to the appropriate hosts:
```
./scripts/upload-encryption-config
```

## Step 5 - Bootstrapping the etcd Cluster
Run the etcd cluster boostrap script:
```
./scripts/bootstrap-etcd
```

### Validate
SSH into a controller node and run the following command:
```
etcdctl --write-out=table --cacert=ca.pem --cert=kubernetes.pem --key=kubernetes-key.pem endpoint status --cluster
```

If all went well, you should see something like the following:
```
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://10.152.47.12:2379 | 30d01160740f2185 |  3.4.14 |   20 kB |     false |      false |         2 |          9 |                  9 |        |
| https://10.152.47.11:2379 | 34d0073e045c58c3 |  3.4.14 |   20 kB |      true |      false |         2 |          9 |                  9 |        |
| https://10.152.47.13:2379 | a6d5fe81fcae23d1 |  3.4.14 |   20 kB |     false |      false |         2 |          9 |                  9 |        |
+---------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

## Step 5 - Bootstrapping the Kubernetes Control Plane
Run the control plane boostrap script:
```
./scripts/bootstrap-control-plane
```

### Validate
SSH into a control plane node and run:
```
kubectl get componentstatuses --kubeconfig admin.kubeconfig
```

You should see something like:
```
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
etcd-1               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"}   
```

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


## Step 1 - Provisioning compute resources

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

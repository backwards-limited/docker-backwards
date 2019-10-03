# Assignment 2

Goals:

- Use different Linux distribution containers to check **curl** CLI tool version

```bash
➜ docker container run --name centos -it --rm centos:7
Unable to find image 'centos:7' locally
7: Pulling from library/centos
d8d02d457314: Pull complete
Digest: sha256:307835c385f656ec2e2fec602cf093224173c51119bbebd602c53c3653a3d6eb
Status: Downloaded newer image for centos:7

[root@894fe6c46456 /]# yum update curl
Loaded plugins: fastestmirror, ovl
...

[root@894fe6c46456 /]# curl --version
curl 7.29.0 (x86_64-redhat-linux-gnu) libcurl/7.29.0 NSS/3.36 zlib/1.2.7 libidn/1.28 libssh2/1.4.3
...
```

```bash
➜ docker container run --name ubuntu -it --rm ubuntu:14.04
...
Status: Downloaded newer image for ubuntu:14.04

root@76496c919f83:/# apt-get update && apt-get install -y curl
Get:1 http://security.ubuntu.com trusty-security InRelease [65.9 kB]
...

root@76496c919f83:/# curl --version
curl 7.35.0 (x86_64-pc-linux-gnu) libcurl/7.35.0 OpenSSL/1.0.1f zlib/1.2.8 libidn/1.28 librtmp/2.3
...
```

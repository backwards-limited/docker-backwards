# Container

- An image is the application we want to run
- A container is an instance of that image running as a process
- You can have many containers running off the same image

## Run

```bash
➜ docker container run --publish 80:80 nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
b8f262c62ec6: Pull complete
e9218e8f93b1: Pull complete
7acba7289aa3: Pull complete
Digest: sha256:aeded0f2a861747f43a01cf1018cf9efe2bdd02afd57d2b11fcc7fcadc16ccd1
Status: Downloaded newer image for nginx:latest
```

```bash
➜ http localhost
HTTP/1.1 200 OK
...
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

and back in the container terminal we see:

```bash
172.17.0.1 - - [29/Sep/2019:17:38:33 +0000] "GET / HTTP/1.1" 200 612 "-" "HTTPie/1.0.3" "-"
```

**So what happened**?

Docker downloaded (if not already downloaded) image nginx from Docker Hub and started a new container.

Port 80 was opened on the host IP -> routing traffic to the container IP with port 80.

```bash
➜ docker container ls
CONTAINER ID   IMAGE  COMMAND                  PORTS                NAMES
250ab76b2ebb   nginx  "nginx -g 'daemon of…"   0.0.0.0:80->80/tcp   nostalgic_chandrasekhar
```

```bash
➜ docker container stop 250
```

```bash
➜ docker container ls
CONTAINER ID   IMAGE  COMMAND                  PORTS                NAMES
```

Command **ls** by default only shows **running** containers.

```bash
➜ docker container ls -a
CONTAINER ID   IMAGE  COMMAND                  STATUS
250ab76b2ebb   nginx  "nginx -g 'daemon of…"   Exited (0) 2 minutes ago
```

## Start

**docker container run** always starts a new container, whereas

**docker container start** will start an existing stopped container.

Now let's run our container again:

```bash
➜ docker container run --publish 80:80 --detach --name webhost nginx
7716fdf5c4439e7000360b61e4d0bffd12a0884b02843a37b7f1614da5d16571

➜ docker container ls -a
CONTAINER ID   IMAGE   STATUS                      PORTS                NAMES
7716fdf5c443   nginx   Up 6 seconds                0.0.0.0:80->80/tcp   webhost
250ab76b2ebb   nginx   Exited (0) About an hour ago                     nostalgic_chandrasekhar
```

## Config / Logs

First get some logging generated:

```bash
➜ http localhost
➜ http localhost
➜ http localhost
```

Then:

```bash
➜ docker container logs webhost
172.17.0.1 - - [29/Sep/2019:19:00:11 +0000] "GET / HTTP/1.1" 200 612 "-" "HTTPie/1.0.3" "-"
172.17.0.1 - - [29/Sep/2019:19:00:13 +0000] "GET / HTTP/1.1" 200 612 "-" "HTTPie/1.0.3" "-"
172.17.0.1 - - [29/Sep/2019:19:00:17 +0000] "GET / HTTP/1.1" 200 612 "-" "HTTPie/1.0.3" "-"
```

```bash
➜ docker container top webhost
PID         USER         TIME          COMMAND
2824        root         0:00          nginx: master process nginx -g daemon off;
2861        101          0:00          nginx: worker process
```

```bash
➜ docker container inspect webhost
[
    {
        "Id": "6a3169d45cfee55c90b15102272d437b02343e074c4b8a4a87d4f6d9be9f7603",
        "Created": "2019-09-30T20:44:43.3692965Z",
        "Path": "nginx",
        ...
```

## Stats

For illustration, start up another container and then view all stats (we can view stats for a specific container):

```bash
➜ docker container run --name mysql -d -p 3306:3306 -e MYSQL_RANDOM_ROOT_PASSWORD=yes mysql
a32a15d65808d5b22e284ce9932a59b56c9b942b502cc30eb4a4b9368d8f8407
```

```bash
➜ docker container stats
CONTAINER ID  NAME    CPU %   MEM USAGE / LIMIT   MEM %    NET I/O     BLOCK I/O           PIDS
a32a15d65808  mysql   0.04%   373MiB / 2.934GiB   12.42%   788B / 0B    8.19kB / 1.26GB    38
6a3169d45cfe  webhost 0.00%   1.824MiB / 2.934GiB 0.06%    1.18kB / 0B  0B / 0B            2
...
```

## Interactive

```bash
➜ docker container run -it --name proxy nginx bash
root@e52cc4cdd961:/#
```

and from another terminal:

```bash
➜ docker container exec -it proxy bash
root@e52cc4cdd961:/#
```

## Network

Each container connected to a private virtual network **bridge** (the default). All containers on a virtual network can talk to each other without **-p** (**--port**). The best practice is to create a new virtual network for each app e.g.

- network **web-app** for mysql and php/apache containers
- network **api** for mongo and nodes containers

Can attach containers to more than one virtual network (or none). Can even skip virtual networks and use host IP by using **--net=host**.

```bash
➜ docker container run --name webhost -d -p 80:80 nginx
5b885fe9c137239d041b32db7663b7fe08341979a42572ae0c5dfda4b7c7dfee

➜ docker container port webhost
80/tcp -> 0.0.0.0:80
```

```bash
➜ docker container inspect --format '{{ .NetworkSettings.IPAddress }}' webhost
172.17.0.2
```

Now is that IP of the container the same as my host?

<pre>
➜ ifconfig en0
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	ether ac:bc:32:c4:d1:ef
	inet6 fe80::4ec:1a14:b7d6:232d%en0 prefixlen 64 secured scopeid 0x5
	<b>inet 192.168.0.3</b> netmask 0xffffff00 broadcast 192.168.0.255
	inet6 fd6e:a34b:4588::14f6:43c9:79a1:df32 prefixlen 64 autoconf secured
	inet6 fd6e:a34b:4588::799e:f426:b6f3:1dc2 prefixlen 64 autoconf temporary
	inet6 2a02:c7f:682:e000:14a1:a248:4839:72be prefixlen 64 autoconf secured
	inet6 2a02:c7f:682:e000:2432:692a:77bf:d753 prefixlen 64 autoconf temporary
	nd6 options=201<PERFORMNUD,DAD>
	media: autoselect
	status: active
</pre>

Not the same!

## Remove (with force)

```bash
➜ docker container rm -f $(docker container ls -aq)
7716fdf5c443
250ab76b2ebb
```


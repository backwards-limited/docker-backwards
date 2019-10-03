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

```bash
➜ docker network ls
NETWORK ID          NAME                     DRIVER              SCOPE
5423f18e63cb        bridge                   bridge              local
297d1ec24777        host                     host                local
eaf9d78e3ee4        none                     null                local
a5318f1eaa28        streams-course_default   bridge              local
```

I see I have an old network hanging around:

```bash
➜ docker network rm streams-course_default
streams-course_default
```

**Network bridge** is the default Docker virtual network which is NAT'ed behind the host IP.

<pre>
➜ docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "5423f18e63cbfdd01f54a98361bdc56a4772922c705c207445d7c4659d692b38",
        "Created": "2019-09-29T15:14:47.697866781Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "49b3eb6aa3914aa8364746172f18997d88dd20f42c6c5888f68fa8edfc86c081": {
                <b>"Name": "webhost"</b>,
                "EndpointID": "410ebf48f110c1a65bc3e039a7cf7e4ef8dc6dc91fcbd9ad89a64966cc103f41",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
</pre>

Let's create our own network:

```bash
➜ docker network create my-app-net
f1218ce6e208fd293d9600cdae6b286d32d88fe0474d45d7c28366954267bcb3

➜ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
5423f18e63cb        bridge              bridge              local
297d1ec24777        host                host                local
f1218ce6e208        my-app-net          bridge              local
eaf9d78e3ee4        none                null                local
```

Create a container on our new network:

```bash
➜ docker container run --name new-nginx -d --network my-app-net nginx
330b2f185472b3dde3e78561c73ed588799e2714d40891dd62fa2bfeb7aea478
```

```bash
➜ docker network inspect my-app-net
[
    {
        "Name": "my-app-net",
        "Id": "f1218ce6e208fd293d9600cdae6b286d32d88fe0474d45d7c28366954267bcb3",
        ...
        "Containers": {
            "330b2f185472b3dde3e78561c73ed588799e2714d40891dd62fa2bfeb7aea478": {
                "Name": "new-nginx",
                "EndpointID": "2574974922ab368b5d2976b9113061b23e7581ce17f1dfdfee96df4cca654bf1",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

## DNS

Docker daemon has a built-in DNS server that containers use by default. Note that Docker defaults the hostname to the  container's name, but you can also set aliases.

Let's add another container to our network:

```bash
➜ docker container run --name my-nginx -d --network my-app-net nginx
380504361bfd86bc5a4aeb9df502315c44ef8374b043e444f8ee5ccbd67d0b75

➜ docker container ls
CONTAINER ID   IMAGE      COMMAND                  PORTS                NAMES
380504361bfd   nginx      "nginx -g 'daemon of…"   80/tcp               my-nginx
172b6d918024   nginx      "nginx -g 'daemon of…"   0.0.0.0:80->80/tcp   webhost
eaa4e51920e6   nginx      "nginx -g 'daemon of…"   80/tcp               new-nginx

➜ docker network inspect my-app-net
[
    {
        "Name": "my-app-net",
        ...
        "Containers": {
            "380504361bfd86bc5a4aeb9df502315c44ef8374b043e444f8ee5ccbd67d0b75": {
                "Name": "my-nginx",
                "EndpointID": "84483a4d85b5eed7e35b21024e19029bfc4047bf5b205a83f06ca66ffcdf0e7c",
                "MacAddress": "02:42:ac:13:00:03",
                "IPv4Address": "172.19.0.3/16",
                "IPv6Address": ""
            },
            "eaa4e51920e6eddbde9c12ebf8b74556fb8b47e026f9e69c51e0f6b518af77f4": {
                "Name": "new-nginx",
                "EndpointID": "a8b884ce7b565510caa4c7594a19baa516bc8838433ff0b14412df1626f396e0",
                "MacAddress": "02:42:ac:13:00:02",
                "IPv4Address": "172.19.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

DNS resolution should work. From one container we should be able to **ping** the other:

```bash
➜ docker container exec -it my-nginx ping new-nginx
OCI runtime exec failed: exec failed: container_linux.go:345: starting container process caused "exec: \"ping\": executable file not found in $PATH": unknown
```

Ha! If we had ping installed:

```bash
➜ docker container exec -it my-nginx /bin/bash
root@380504361bfd:/# apt-get update
...
Reading package lists... Done

root@380504361bfd:/# apt-get install -y inetutils-ping
...
Setting up inetutils-ping (2:1.9.4-7) ...
Processing triggers for libc-bin (2.28-10) ...
root@380504361bfd:/# exit
```

And try again:

```bash
➜ docker container exec -it my-nginx ping new-nginx
PING new-nginx (172.19.0.2): 56 data bytes
64 bytes from 172.19.0.2: icmp_seq=0 ttl=64 time=0.693 ms
...
```

Regarding the default **bridge** network, you need to use the **--link** when creating a new container.

## Remove (with force)

```bash
➜ docker container rm -f $(docker container ls -aq)
7716fdf5c443
250ab76b2ebb
```


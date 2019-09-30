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

## Remove (with force)

```bash
➜ docker container rm -f $(docker container ls -aq)
7716fdf5c443
250ab76b2ebb
```


# Container Lifetime and Volumes

- Volumes - Special location outside of container UFS (union file system)
- Bind mounts - link container path to host path (i.e. mount a volume)

A Dockerfile can declare a **Volume** (or more) which states where data will be written to e.g the **mysql** official Docker file includes:

```dockerfile
VOLUME /var/lib/mysql
```

This volume would outlive the container until someone deletes said volume.

## Data Volume

Before we begin, and if you don't mind losing anything:

```bash
➜ docker volume prune
```

```bash
➜ docker image pull mysql
```

```bash
➜ docker image inspect mysql
[
    {
        ...
        "Config": {
            ...
            "Image": "sha256:231b50bbbc3f4606a0a7c527c63f9d447e7c18592433bf82ad4692787bf925ab",
            "Volumes": {
                "/var/lib/mysql": {}
            },
            ...
```

If we run mysql we will see that even though the containerized version of mysql thinks it is accessing data at **/var/lib/mysql**, the actual location on the host itself will be a tad different - the container get its own unique location on the host, as we can see from a **docker container inspect** (instead of the previous **docker image inspect**):

```bash
➜ docker container run -d --name mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql
```

```bash
➜ docker container inspect mysql
[
    {
        "Id": "57efc380a0ef56d308c30b4cb15955eab1d3a2c147f7e12f2a0750e6f309ecc8",
        ...
        "Mounts": [
            {
                "Type": "volume",
                "Name": "63554bb1d757a7b2e594654771241f8c02451bed2399fa1a771484e8b8d06e74",
                "Source": "/var/lib/docker/volumes/63554bb1d757a7b2e594654771241f8c02451bed2399fa1a771484e8b8d06e74/_data",
                "Destination": "/var/lib/mysql",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
        "Config": {
            ...
            "Env": [
                "MYSQL_ALLOW_EMPTY_PASSWORD=true",
                ...
            ],
            ...
            "Image": "mysql",
            "Volumes": {
                "/var/lib/mysql": {}
            },
            ...
```

```bash
➜ docker volume ls
DRIVER              VOLUME NAME
local               63554bb1d757a7b2e594654771241f8c02451bed2399fa1a771484e8b8d06e74
```

```bash
➜ docker volume inspect 63554bb1d757a7b2e594654771241f8c02451bed2399fa1a771484e8b8d06e74
[
    {
        "CreatedAt": "2019-10-11T20:18:16Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/63554bb1d757a7b2e594654771241f8c02451bed2399fa1a771484e8b8d06e74/_data",
        "Name": "63554bb1d757a7b2e594654771241f8c02451bed2399fa1a771484e8b8d06e74",
        "Options": null,
        "Scope": "local"
    }
]
```

Can we actually go to that location (the **Mountpoint**) on our host? Yes if running on Linux. If running on Mac, then Docker for Mac set up a Linux VM which holds the Mountpoint and where the container is actually running.

Let's start a second mysql:

```bash
➜ docker container run -d --name mysql2 -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql
```

```bash
➜ docker volume ls
DRIVER              VOLUME NAME
local               63554bb1d757a7b2e594654771241f8c02451bed2399fa1a771484e8b8d06e74
local               f2a1ac6f9aa163e8323d20be310e7083ddd83f06b92cfa083bdf4e9e9de3667b
```

Let's stop both containers:

```bash
➜ docker container stop mysql mysql2
mysql
mysql2

➜ docker container ls
CONTAINER ID    IMAGE    COMMAND                  STATUS                        NAMES

➜ docker container ls -a
CONTAINER ID    IMAGE    COMMAND                  STATUS                        NAMES
21838f4519d3    mysql    "docker-entrypoint.s…"   Exited (0) 39 seconds ago     mysql2
57efc380a0ef    mysql    "docker-entrypoint.s…"   Exited (0) 40 seconds ago     mysql
```

Can we prove that our data will be safe? Let's remove the containers:

```bash
➜ docker container rm -f $(docker container ls -aq)

➜ docker volume ls
DRIVER              VOLUME NAME
local               63554bb1d757a7b2e594654771241f8c02451bed2399fa1a771484e8b8d06e74
local               f2a1ac6f9aa163e8323d20be310e7083ddd83f06b92cfa083bdf4e9e9de3667b
```

Ha! Of course we don't know which is which. How about a **named volume**:

```bash
➜ docker container run -d --name mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=true -v mysql-db:/var/lib/mysql mysql
3714880d5f8320d6d0b216ddb8d732c3f0380e4def260c2b4f9b36c75a4a1140

➜ docker volume ls
DRIVER              VOLUME NAME
local               63554bb1d757a7b2e594654771241f8c02451bed2399fa1a771484e8b8d06e74
local               f2a1ac6f9aa163e8323d20be310e7083ddd83f06b92cfa083bdf4e9e9de3667b
local               mysql-db

➜ docker volume inspect mysql-db
[
    {
        "CreatedAt": "2019-10-11T21:49:34Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/mysql-db/_data",
        "Name": "mysql-db",
        "Options": null,
        "Scope": "local"
    }
]
```

## Bind Mounting

- Map a host file or directory to a container file or directory
- Cannot be used in Dockerfile - must be at **container run**
- Differs from previous **run** command by specifying actual host location starting with **/** e.g.
  - run -v /Users/davidainslie/stuff:/path/container

Let's take another look at [Dockerfile](../dockerfiles/2/Dockerfile) where there is also [index.html](../dockerfiles/2/index.html) and if we bind said location at runtime, we can edit the html outside the container and see the effects take place inside. So, in the directory of [Dockerfile](../dockerfiles/2):

```bash
docker-backwards/courses/docker-mastery/dockerfiles/2
➜ docker container run -d --name nginx -p 80:80 -v $(pwd):/usr/share/nginx/html nginx
be09c307d96329ff618cf48a3648e0f398c3c26e44fa95a8b1c52d3d35aad76d
```

```bash
➜ http localhost
HTTP/1.1 200 OK
...
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Your 2nd Dockerfile worked!</title>
</head>

<body>
  <h1>You just successfully ran a container with a custom file copied into the image at build time!</h1>
</body>
</html>
```

**See what happened?** We used the official nginx and yet viewed (using http, curl or browser) our custom index.html because of the binding.

Run the official image again without the binding (and on different port) to see default html:

```bash
docker-backwards/courses/docker-mastery/dockerfiles/2
➜ docker container run -d --name nginx2 -p 8080:80 nginx
```

```bash
➜ http localhost:8080
HTTP/1.1 200 OK
...
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>
<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```


# Dockerfile

```bash
$ docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL   SWARM   DOCKER    ERRORS
default   -        virtualbox   Stopped                 Unknown
```

Write a simple [Dockerfile](../docker/dockerfile):

```dockerfile
FROM ubuntu:latest
LABEL author = davidainslie

RUN apt-get update
RUN apt-get install -y nodejs nodejs-legacy npm
```

and build:

```bash
$ docker build -t nodejs:0.1 .
```

```bash
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
nodejs              0.1                 2f2c3085aecd        About a minute ago   425MB
ubuntu              latest              94e814e2efa8        5 weeks ago          88.9MB
...
```

Let's check that Nodejs is correctly installed as a layer (image) within our new image:

```bash
$ docker run nodejs:0.1 node -v
v8.10.0
```

There are actually additional images (from the newly created layers):

```bash
$ docker images -a
REPOSITORY       TAG                 IMAGE ID            CREATED             SIZE
nodejs           0.1                 2f2c3085aecd        6 minutes ago       425MB
<none>           <none>              ad00f7a7fa34        7 minutes ago       114MB
<none>           <none>              8acfab17dcce        7 minutes ago       88.9MB
ubuntu           latest              94e814e2efa8        5 weeks ago         88.9MB
```

To see each image / layer from building:

```bash
$ docker history nodejs:0.1
IMAGE           CREATED             CREATED BY                                      SIZE
2f2c3085aecd    8 minutes ago       /bin/sh -c apt-get install -y nodejs npm        311MB
ad00f7a7fa34    9 minutes ago       /bin/sh -c apt-get update                       25.3MB
8acfab17dcce    9 minutes ago       /bin/sh -c #(nop)  LABEL author== davidainsl…   0B
94e814e2efa8    5 weeks ago         /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
<missing>       5 weeks ago         /bin/sh -c mkdir -p /run/systemd && echo 'do…   7B
<missing>       5 weeks ago         /bin/sh -c rm -rf /var/lib/apt/lists/*          0B
<missing>       5 weeks ago         /bin/sh -c set -xe   && echo '#!/bin/sh' > /…   745B
<missing>       5 weeks ago         /bin/sh -c #(nop) ADD file:1d7cb45c4e196a6a8…   88.9MB
```

Add another command to our Dockerfile to observe caching:

```dockerfile
RUN apt-get clean
```

and build a new version:

```bash
$ docker build -t nodejs:0.2 .
Sending build context to Docker daemon  2.048kB
Step 1/5 : FROM ubuntu:latest
 ---> 94e814e2efa8
Step 2/5 : LABEL author = davidainslie
 ---> Using cache
 ---> 8acfab17dcce
Step 3/5 : RUN apt-get update
 ---> Using cache
 ---> ad00f7a7fa34
Step 4/5 : RUN apt-get install -y nodejs npm
 ---> Using cache
 ---> 2f2c3085aecd
Step 5/5 : RUN apt-get clean
 ---> Running in 43698bb8d4a8
Removing intermediate container 43698bb8d4a8
 ---> a063f9095691
Successfully built a063f9095691
Successfully tagged nodejs:0.2
```

Much quicker and observe the **cache**.

With Dockerfile copied over to our [microservice](../microservice) we can add this microservice as another layer.

We add 2 commands and then build:

```dockerfile
FROM ubuntu:latest

LABEL author = davidainslie

RUN apt-get update

RUN apt-get install -y nodejs npm

RUN apt-get clean

# Our microservice

COPY . src/

RUN cd src && npm install
```

```bash
$ docker build -t microservice:0.1 .
```

However, this is now a sub-optimal Dockerfile:

```bash
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
microservice        0.1                 a1d731f4c1d7        About a minute ago   431MB
nodejs              0.2                 a063f9095691        9 minutes ago        425MB
nodejs              0.1                 2f2c3085aecd        22 minutes ago       425MB
ubuntu              latest              94e814e2efa8        5 weeks ago          88.9MB
```

With the following optimised Dockerfile, the layer **RUN cd src && npm install** will not have to run each time as it will be cached - though it will be run if **package.json** changes. However, we can add, delete and change files within **src** which will only affect the final layer:

```dockerfile
FROM ubuntu:latest

LABEL author = davidainslie

RUN apt-get update

RUN apt-get install -y nodejs npm

RUN apt-get clean

# Our microservice

COPY ./package.json src/

RUN cd src && npm install

COPY . src/
```

Rebuild:

```bash
$ docker build -t microservice:0.2 .
```

Finally, state the working directory and give a default command (**CMD**) to run when instantiating a container i.e. when no command is given to **docker run**:

```dockerfile
FROM ubuntu:latest

LABEL author = davidainslie

RUN apt-get update

RUN apt-get install -y nodejs npm

RUN apt-get clean

# Our microservice

COPY ./package.json src/

RUN cd src && npm install

COPY . src/

WORKDIR src/

CMD ["npm", "start"]
```

Rebuild:

```bash
$ docker build -t microservice:0.3 .
```

```bash
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
microservice        0.3                 41112b253cad        29 seconds ago      444MB
<none>              <none>              fe84e2bb644b        5 minutes ago       444MB
microservice        0.2                 b4daa5566862        5 minutes ago       444MB
microservice        0.1                 a1d731f4c1d7        16 minutes ago      431MB
nodejs              0.2                 a063f9095691        24 minutes ago      425MB
nodejs              0.1                 2f2c3085aecd        37 minutes ago      425MB
ubuntu              latest              94e814e2efa8        5 weeks ago         88.9MB
```

When we run, we can accept the default command:

```bash
$ docker run -d -p 9000:3000 microservice:0.3
2600df9e53730d2aa62a81460ac79e5c476ab64b1a58a112911eaa2fe15780d8
```

```bash
$ http localhost:9000
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 170
Content-Type: text/html; charset=utf-8
Date: Tue, 16 Apr 2019 20:56:11 GMT
ETag: W/"aa-z+ebXSEdArbZ+EXlN/WQjf6HV8c"
X-Powered-By: Express

<!DOCTYPE html><html><head><title>Express</title><link rel="stylesheet" href="/stylesheets/style.css"></head><body><h1>Express</h1><p>Welcome to Express</p></body></html>
```


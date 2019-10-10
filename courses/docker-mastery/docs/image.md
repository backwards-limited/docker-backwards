# Image

What is in an image?

- Application binaries and dependencies
- Metadata about the image data and how to run the image

The image is not a complete OS. So there is no kernel or kernel modules (e.g. drivers) as opposed to traditional VM.

## Layers

```bash
➜ docker image history nginx:latest
IMAGE               CREATED             CREATED BY                                      SIZE
f949e7d76d63        10 days ago         /bin/sh -c #(nop)  CMD ["nginx" "-g" "daemon…   0B
<missing>           10 days ago         /bin/sh -c #(nop)  STOPSIGNAL SIGTERM           0B
<missing>           10 days ago         /bin/sh -c #(nop)  EXPOSE 80                    0B
<missing>           10 days ago         /bin/sh -c ln -sf /dev/stdout /var/log/nginx…   22B
<missing>           10 days ago         /bin/sh -c set -x     && addgroup --system -…   56.8MB
<missing>           10 days ago         /bin/sh -c #(nop)  ENV PKG_RELEASE=1~buster     0B
<missing>           10 days ago         /bin/sh -c #(nop)  ENV NJS_VERSION=0.3.5        0B
<missing>           10 days ago         /bin/sh -c #(nop)  ENV NGINX_VERSION=1.17.4     0B
<missing>           3 weeks ago         /bin/sh -c #(nop)  LABEL maintainer=NGINX Do…   0B
<missing>           3 weeks ago         /bin/sh -c #(nop)  CMD ["bash"]                 0B
<missing>           3 weeks ago         /bin/sh -c #(nop) ADD file:1901172d265456090…   69.2MB
```

The above command shows layers of changes in an image. And to get metadata:

```bash
➜ docker image inspect nginx
[
    {
        "Id": "sha256:f949e7d76d63befffc8eec2cbf8a6f509780f96fb3bacbdc24068d594a77f043",
        "RepoTags": [
            "nginx:latest"
        ],
        "RepoDigests": [
            "nginx@sha256:aeded0f2a861747f43a01cf1018cf9efe2bdd02afd57d2b11fcc7fcadc16ccd1"
        ],
        "Parent": "",
        "Comment": "",
        "Created": "2019-09-24T23:33:17.034191345Z",
        "Container": "876f5ecccea7b46d47165128e16e9f1e2a77989cf07d7586d3dd4d186387a519",
        ...
```

A **container** is just a single **read/write** layer on top of an image.

## Tag

We could tag some image; say an official image which has no user name e.g.

```bash
➜ docker image tag nginx davidainslie/nginx

➜ docker image ls
REPOSITORY             TAG            IMAGE ID            CREATED             SIZE
davidainslie/nginx     latest         f949e7d76d63        10 days ago         126MB
nginx                  latest         f949e7d76d63        10 days ago         126MB
...
```

Notice the same image ID - we didn't actually change anything, just created a new tag, which we could **push**.

## Dockerfile

A recipe to create an image.

Note regarding symbolic link and good practice in a Dockerfile. A symbolic link is declared as:

```bash
➜ ln -s {source-filename} {symbolic-filename}
```

and it is good practice to link a container's log files to **stdout** and **stderror** e.g. for nginx:

```dockerfile
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
```

Let's build [Dockerfile-1](../dockerfiles/Dockerfile-1):

```bash
➜ docker image build -t my-nginx -f Dockerfile-1 .
Sending build context to Docker daemon  36.35kB
Step 1/7 : FROM debian:stretch-slim
stretch-slim: Pulling from library/debian
...
```

```bash
➜ docker image ls
REPOSITORY           TAG           IMAGE ID            CREATED             SIZE
my-nginx             latest        1a39698b1b64        40 seconds ago      108MB
centos               latest        0f3e07c0138f        3 days ago          220MB
davidainslie/nginx   latest        f949e7d76d63        10 days ago         126MB
...
```

**THINGS THAT CHANGE THE MOST SHOULD BE TOWARDS THE BOTTOM OF DOCKERFILE.**

Let's build [Dockerfile 2](../dockerfiles/2/Dockerfile):

```bash
➜ docker image build -t nginx-with-html .
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM nginx:latest
 ---> f949e7d76d63
Step 2/3 : WORKDIR /usr/share/nginx/html
 ---> Running in 79858e994710
Removing intermediate container 79858e994710
 ---> 8d9de0d406ea
Step 3/3 : COPY index.html index.html
 ---> d077357c356b
Successfully built d077357c356b
Successfully tagged nginx-with-html:latest
```

```bash
➜ docker container run --rm -p 80:80 nginx-with-html
```

```bash
➜ http localhost:80
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

And if we wanted to tag to push:

```bash
➜ docker image tag nginx-with-html:latest davidainslie/nginx-with-html:latest

➜ docker image push davidainslie/nginx-with-html:latest
```


# Introduction

Run a docker ubuntu image:

```bash
$ docker search ubuntu
NAME                             DESCRIPTION                                     STARS
ubuntu                           Ubuntu is a Debian...                           9405
dorowu/ubuntu-desktop-lxde-vnc   Docker image to provide HTML5 VNC interface …   292
rastasheep/ubuntu-sshd           Dockerized SSH service, built on top of offi…   211
consol/ubuntu-xfce-vnc           Ubuntu container with "headless" VNC session…   173
...
```

Refine our search to show only images with at least 1000 stars:

```bash
$ docker search --filter=stars=1000 ubuntu
NAME                DESCRIPTION                                     STARS       OFFICIAL
ubuntu              Ubuntu is a Debian-based Linux operating sys…   9405        [OK]
```

Let's run:

```bash
$ docker run -it ubuntu /bin/bash
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
898c46f3b1a1: Pull complete
63366dfa0a50: Pull complete
041d4cd74a92: Pull complete
6e1bee0f8701: Pull complete
Digest: sha256:017eef0b616011647b269b5c65826e2e2ebddbe5d1f8c1e56b3599fb14fabec8
Status: Downloaded newer image for ubuntu:latest
root@62ed7e7d35fb:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

Within the container, we can install everything we need. For this example we need Nodejs.

```bash
root@a49961c0f36a:/# apt-get update

root@a49961c0f36a:/# apt-get install vim
```

```bash
root@62ed7e7d35fb:/# vim install-node.sh
```

And type in the following:

```bash
apt-get update
apt-get install --yes nodejs
apt-get install --yes nodejs-legacy
apt-get install --yes npm
```

And run said script:

```bash
root@a49961c0f36a:/# bash install-node.sh
```

Check node is installed:

```bash
root@a49961c0f36a:/# node -v
v8.10.0
```

Now we want to create a new docker image from this container which has Nodejs. We achieve this with the **docker commit** command.

```bash
$ docker ps -a
CONTAINER ID  IMAGE   COMMAND      CREATED         STATUS                  PORTS   NAMES
a49961c0f36a  ubuntu  "/bin/bash"  10 minutes ago  Exited (0) 3 seconds ago     elated_joliot
```

```bash
$ docker commit -a davidainslie a49961c0f36a ubuntu-node:0.1
sha256:b5d3acd155d1fa622d4febfd291750c8a4409254697f50b2655973210014f533
```


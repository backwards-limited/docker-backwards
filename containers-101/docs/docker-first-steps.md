# Docker First Steps

## Run an Official Docker Image

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

## Create a New Base Image

Now that we have an ubuntu instance, within the container, we can install everything we need. For this example we need Nodejs.

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

Do we have a new image?

```bash
$ docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
ubuntu-node             0.1                 b5d3acd155d1        About an hour ago   472MB
ubuntu                  latest              94e814e2efa8        4 weeks ago         88.9MB
...
```

## Build a Microservice

Create a skeleton service using **express generator**:

```bash
$ npm install -g express-generator
```

```bash
$ express microservice

  warning: the default view engine will not be jade in future releases
  warning: use `--view=jade' or `--help' for additional options


   create : microservice/
   create : microservice/public/
   create : microservice/public/javascripts/
   create : microservice/public/images/
   create : microservice/public/stylesheets/
   create : microservice/public/stylesheets/style.css
   create : microservice/routes/
   create : microservice/routes/index.js
   create : microservice/routes/users.js
   create : microservice/views/
   create : microservice/views/error.jade
   create : microservice/views/index.jade
   create : microservice/views/layout.jade
   create : microservice/app.js
   create : microservice/package.json
   create : microservice/bin/
   create : microservice/bin/www

   change directory:
     $ cd microservice

   install dependencies:
     $ npm install

   run the app:
     $ DEBUG=microservice:* npm start
```

Under the [routes](../microservice/routes) directory we shall create a new file [api.js](../microservice/routes/api.js) with the following:

```javascript
var express = require("express");
var router = express.Router();

/* GET greeting */
router.get("/sayhello", function(req, res) {
  res.send("Hello there!");
});

module.exports = router;
```

And add a reference to this new file within [app.js](../microservice/app.js), with the following two lines:

```javascript
var apiRouter = require("./routes/api");
...
app.use("/api", apiRouter);
```

Run locally to see that it works (before we dockerise):

```bash
$ npm install

$ npm start
```

Check it:

```bash
$ http localhost:3000/api/sayhello
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 12
Content-Type: text/html; charset=utf-8
Date: Sun, 14 Apr 2019 19:03:55 GMT
ETag: W/"c-axnLN5C22o98NLTYiV14pW0HhiQ"
X-Powered-By: Express

Hello there!
```

## Dockerise our Microservice

We can do this by mounting a **volume** when we run docker with our new base image **ubuntu-node**:

```bash
$ docker run -it -v $(pwd):/host -p 9000:3000 ubuntu-node:0.1 /bin/bash
root@6df8d42d95da:/# ls
bin  boot  dev  etc  home  host  install-node.sh  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

root@6df8d42d95da:/# ls host
app.js  bin  node_modules  package-lock.json  package.json  public  routes  views
```

The mounting is temporary for this running docker instance. So let's copy our microservice files:

```bash
root@6df8d42d95da:/# cp -r /host /microservice
```

Let's again run our service, now within the container:

```bash
root@6df8d42d95da:/# cd microservice/

root@6df8d42d95da:/microservice# npm start

> microservice@0.0.0 start /microservice
> node ./bin/www
```

In another terminal we can this time access **port 9000**:

```bash
$ http localhost:9000/api/sayhello
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 12
Content-Type: text/html; charset=utf-8
Date: Sun, 14 Apr 2019 19:46:58 GMT
ETag: W/"c-axnLN5C22o98NLTYiV14pW0HhiQ"
X-Powered-By: Express

Hello there!
```

Now we can create a new image that not only has our original base of ubuntu and Nodejs but also include our new microservice:

```bash
$ docker ps -a
CONTAINER ID    IMAGE            COMMAND      STATUS                        NAMES
6df8d42d95da    ubuntu-node:0.1  "/bin/bash"  Exited (130) 14 seconds ago   youthful_williams

$ docker commit -a davidainslie 6df8d42d95da node-microservice:0.1
sha256:dac0c3edd8483460d3992ba12a09cb1510a24374e2df0c65f5b43875fd705d0c
```

```bash
$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
node-microservice     0.1                 dac0c3edd848        2 minutes ago       478MB
ubuntu-node           0.1                 b5d3acd155d1        2 hours ago         472MB
ubuntu                latest              94e814e2efa8        4 weeks ago         88.9MB
...
```

So, can we run our new microservice as a docker container?

We can specify a working directory that we want the issued command to run in, using **-w**:

```bash
$ docker run -d -w /microservice -p 9000:3000 node-microservice:0.1 npm start
1ef136ea296baec35b88006559927892df21a4d29dd73f28818a1eccd3381858
```

```bash
$ docker ps
CONTAINER ID    IMAGE                  COMMAND        PORTS                    NAMES
1ef136ea296b    node-microservice:0.1  "npm start"    0.0.0.0:9000->3000/tcp   brave_lovelace
```

Check again:

```bash
$ http localhost:9000/api/sayhello
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 12
Content-Type: text/html; charset=utf-8
Date: Sun, 14 Apr 2019 20:06:27 GMT
ETag: W/"c-axnLN5C22o98NLTYiV14pW0HhiQ"
X-Powered-By: Express

Hello there!
```

If we run the above **httpie** command again while **attached** to the container, we see the following:

```bash
$ docker attach 1ef136ea296b
GET /api/sayhello 200 0.688 ms - 12
```

## Push to Dockerhub

Firstly, let's add a **latest** tag allowing anyone to pull our image without having to specify a tag (since as things stand, tag 0.1 has to always be specified):

```bash
$ docker images
REPOSITORY             TAG         IMAGE ID            CREATED             SIZE
node-microservice      0.1         dac0c3edd848        21 minutes ago      478MB
ubuntu-node            0.1         b5d3acd155d1        3 hours ago         472MB
ubuntu                 latest      94e814e2efa8        4 weeks ago         88.9MB
...
```

```bash
$ docker tag node-microservice:0.1 node-microservice:latest

$ docker images
REPOSITORY             TAG         IMAGE ID            CREATED             SIZE
node-microservice      0.1         dac0c3edd848        22 minutes ago      478MB
node-microservice      latest      dac0c3edd848        22 minutes ago      478MB
ubuntu-node            0.1         b5d3acd155d1        3 hours ago         472MB
ubuntu                 latest      94e814e2efa8        4 weeks ago         88.9MB
...
```

Secondly, before pushing to dockerhub let's tag with our user name:

```bash
$ docker tag node-microservice davidainslie/node-microservice

$ docker images
REPOSITORY                       TAG      IMAGE ID            CREATED             SIZE
davidainslie/node-microservice   latest   dac0c3edd848        26 minutes ago      478MB
node-microservice                0.1      dac0c3edd848        26 minutes ago      478MB
node-microservice                latest   dac0c3edd848        26 minutes ago      478MB
ubuntu-node                      0.1      b5d3acd155d1        3 hours ago         472MB
ubuntu                           latest   94e814e2efa8        4 weeks ago         88.9MB
...
```


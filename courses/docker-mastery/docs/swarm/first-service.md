# First Service

```bash
➜ docker info
Client:
 Debug Mode: false

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 16
 ...
 Swarm: inactive
 ...
 Product License: Community Engine
```

Boot a single node Swarm:

```bash
➜ docker swarm init
Swarm initialized: current node (52sqyzh8ntk8wdmqus0zh7auu) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-2e85uiibpyytnomt1zsgj9uxgpspaz0tfn5ge5mvpsaurgfjp0-6i060v032gr3x1ch4nw3tfzwo 192.168.65.3:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

```bash
➜ docker node ls
ID                           HOSTNAME        STATUS AVAILABILITY MANAGER STATUS  ENGINE VERSION
52sqyzh8ntk8wdmqus0zh7auu *  docker-desktop  Ready  Active       Leader          19.03.4
```

The **service** Swarm command is the equivalent of **run** for Docker.

Let's take the Google DNS server at 8.8.8.8 and ping it from a Swarm service (instead of direct):

```bash
➜ docker service create alpine ping 8.8.8.8
rxi4eceiwlq9we0zh7px07tbo
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
```

```bash
➜ docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
rxi4eceiwlq9        sleepy_thompson     replicated          1/1                 alpine:latest
```

```bash
➜ docker service ps sleepy_thompson
ID           NAME               IMAGE          NODE            DESIRED STATE  CURRENT STATE
woi7gya1ue49 sleepy_thompson.1  alpine:latest  docker-desktop  Running        Running 2 minutes
```

Let's scale up the service:

```
➜ docker service update sleepy_thompson --replicas 3
sleepy_thompson
overall progress: 3 out of 3 tasks
1/3: running   [==================================================>]
2/3: running   [==================================================>]
3/3: running   [==================================================>]
verify: Service converged
```

```bash
➜ docker service ls
ID              NAME               MODE           REPLICAS      IMAGE             PORTS
rxi4eceiwlq9    sleepy_thompson    replicated     3/3           alpine:latest
```

```bash
➜ docker service ps sleepy_thompson
ID             NAME              IMAGE          NODE            DESIRED STATE     CURRENT STATE
woi7gya1ue49   sleepy_thompson.1 alpine:latest  docker-desktop  Running       Running 9 minutes
vso9m4bcpypn   sleepy_thompson.2 alpine:latest  docker-desktop  Running       Running 2 minutes
c4jhchoqg2xw   sleepy_thompson.3 alpine:latest  docker-desktop  Running       Running 2 minutes
```

Let's kill one of our three containers to see Swarm self management in action:

```bash
➜ docker container ls
CONTAINER ID    IMAGE           COMMAND             NAMES
a6e2717e7f82    alpine:latest   "ping 8.8.8.8"      sleepy_thompson.2.vso9m4bcpypn29e6yiakklmq3
15e2df6579f7    alpine:latest   "ping 8.8.8.8"      sleepy_thompson.3.c4jhchoqg2xwjwpxmuyhe36n5
9c9bbae5b33a    alpine:latest   "ping 8.8.8.8"      sleepy_thompson.1.woi7gya1ue49vb64lyrrqs74t
```

```bash
➜ docker container rm -f sleepy_thompson.1.woi7gya1ue49vb64lyrrqs74t
sleepy_thompson.1.woi7gya1ue49vb64lyrrqs74t
```

```bash
➜ docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE
rxi4eceiwlq9        sleepy_thompson     replicated          2/3                 alpine:latest
```

```bash
➜ docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE
rxi4eceiwlq9        sleepy_thompson     replicated          3/3                 alpine:latest
```

Let's see the service history to when the container went down and when it was replaced:

```bash
➜ docker service ps sleepy_thompson
ID            NAME                IMAGE          NODE            DESIRED STATE  CURRENT STATE
lxkapsdbtdl9  sleepy_thompson.1   alpine:latest  docker-desktop  Running      Running 2 minutes
woi7gya1ue49  \_ sleepy_thompson.1 alpine:latest docker-desktop  Shutdown     Failed 2 minutes     "task: non-zero exit (137)"
vso9m4bcpypn  sleepy_thompson.2   alpine:latest  docker-desktop  Running     Running 13 minutes
c4jhchoqg2xw  sleepy_thompson.3   alpine:latest  docker-desktop  Running     Running 13 minutes
```

And bring down the service:

```bash
➜ docker service rm sleepy_thompson
sleepy_thompson
```

```bash
➜ docker service ls
ID           NAME          MODE        REPLICAS        IMAGE         PORTS
```

```bash
➜ docker container ls
CONTAINER ID     IMAGE     COMMAND     CREATED      STATUS      PORTS      NAMES
```


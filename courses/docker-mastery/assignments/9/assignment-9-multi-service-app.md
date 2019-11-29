# Assignment 9 - Multi Service App

Goal - Create networks, volumes and services for a web based "cats vs dogs" voting app.

- Use Docker's Distributed Voting App
- 1 volume; 2 networks; 5 services

![Architecture](architecture.png)

## Solution Steps

Create 3 nodes and ssh onto them:

```bash
➜ docker-machine create node1

➜ docker-machine ssh node1
```

```bash
➜ docker-machine create node2

➜ docker-machine ssh node2
```

```bash
➜ docker-machine create node3

➜ docker-machine ssh node3
```

From node1 initialise the Swarm (choosing the second IP):

```bash
docker@node1:~$ docker swarm init
Error response from daemon: could not choose an IP address to advertise since this system has multiple addresses on different interfaces (10.0.2.15 on eth0 and 192.168.99.130 on eth1) - specify one with --advertise-addr
docker@node1:~$ docker swarm init --advertise-addr 192.168.99.130
Swarm initialized: current node (g33yiwy7uwsk53ka5uyz8yyjl) is now a manager.

To add a worker to this swarm, run the following command:
    docker swarm join --token SWMTKN-1-3rjcgxuco9ae17gamga20b82490asxub6i0tqvt8elfq100cff-am0270kf1vgyo474nj39bjkkq 192.168.99.130:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

On nodes 2 and 3:

```bash
docker@node2:~$ docker swarm join --token SWMTKN-1-3rjcgxuco9ae17gamga20b82490asxub6i0tqvt8elfq100cff-am0270kf1vgyo474nj39bjkkq 192.168.99.130:2377
```

```bash
docker@node3:~$ docker swarm join --token SWMTKN-1-3rjcgxuco9ae17gamga20b82490asxub6i0tqvt8elfq100cff-am0270kf1vgyo474nj39bjkkq 192.168.99.130:2377
```

From node 1 create a **frontend** and **backend** overlay network:

```bash
docker@node1:~$ docker network create --driver overlay frontend
```

```bash
docker@node1:~$ docker network create --driver overlay backend
```

Create services:

```bash
docker@node1:~$ docker service create bretfisher/examplevotingapp_vote --name vote --network frontend -p 80:80 --replicas 2
```

```bash
docker@node1:~$ docker service create redis:5/0.7 --name redis --network frontend --replicas 1
```

```bash
docker@node1:~$ docker service create bretfisher/examplevotingapp_worker:java --name worker --network frontend --network backend --replicas 1
```

```bash
docker@node1:~$ docker service create postgres:9.4 --name db --network backend --replicas 1 --mount type=volume,source=db-data,target=/var/lib/postgresql/data
```

```bash
docker@node1:~$ docker service create bretfisher/examplevotingapp_result --name result --network backend -p 5001:80 --replicas 1
```

The above is all the script [create-services.sh](create-services.sh). We need to perform a **secure copy** to say node 1:

```bash
➜ docker-machine scp create-services.sh docker@node1:~/
create-services.sh
```

```bash
➜ docker-machine ssh node1
   
docker@node1:~$ ls -las
...
     4 -rwxr-xr-x    1 docker   staff          678 Nov 25 23:14 create-services.sh
```

and run:

```bash
docker@node1:~$ ./create-services.sh
```


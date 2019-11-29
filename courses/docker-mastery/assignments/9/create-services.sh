#!/bin/sh

docker network create --driver overlay frontend

docker network create --driver overlay backend

docker service create bretfisher/examplevotingapp_vote --name vote --network frontend -p 80:80 --replicas 2

docker service create redis:3.2 --name redis --network frontend --replicas 1

docker service create bretfisher/examplevotingapp_worker:java --name worker --network frontend --network backend --replicas 1

docker service create postgres:9.4 --name db --network backend --replicas 1 --mount type=volume,source=db-data,target=/var/lib/postgresql/data

docker service create bretfisher/examplevotingapp_result --name result --network backend -p 5001:80 --replicas 1
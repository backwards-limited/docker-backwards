# Secrets

- Easiest **secure** solution for storing secrets in Swarm
- What is a Secret?
  - User names and passwords
  - TLS certificates and keys
  - SSH keys
  - Any data you would prefer not be *on front page of news*
- Supports generic strings or binary content up to 500Kb in size

## Service

With our usual 3 nodes up and running. Peform the following copy:

```bash
➜ docker-machine scp psql-user.txt docker@node1:~/
```

Create secrets:

```bash
docker@node1:~$ cat psql-user.txt
mypsqluser

docker@node1:~$ docker secret create psql-user psql-user.txt
7cogato43vlwzeafg9rms7cvk

docker@node1:~$ echo "myDBpassWORD" | docker secret create psql-pass -
tww19my5k90cteb9huzvrjxix
```

```bash
docker@node1:~$ docker secret ls
ID                          NAME       DRIVER       CREATED              UPDATED
tww19my5k90cteb9huzvrjxix   psql-pass               About a minute ago   About a minute ago
7cogato43vlwzeafg9rms7cvk   psql-user               2 minutes ago        2 minutes ago
```

Create a service with the secrets:

```bash
docker@node1:~$ docker service create --name psql \
  --secret psql-user \
  --secret psql-pass \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/psql-pass \
  -e POSTGRES_USER_FILE=/run/secrets/psql-user \
  postgres
ib5ire6kbsl0zemndx9dhee51
```

```bash
docker@node1:~$ docker service ps psql
ID             NAME     IMAGE             NODE    DESIRED STATE   CURRENT STATE   ERROR   PORTS
jp1s8pvt22h6   psql.1   postgres:latest   node1   Running         Running about a minute ago
```

```bash
docker@node1:~$ docker container ls
CONTAINER ID     IMAGE               PORTS        NAMES
2dd2251c80aa     postgres:latest     5432/tcp     psql.1.jp1s8pvt22h6mqjxecpsii0tw
```

```bash
root@2dd2251c80aa:/# ls /run/secrets
psql-pass  psql-user
```

```bash
root@2dd2251c80aa:/# cat /run/secrets/psql-user
mypsqluser
```

## Stack

With our usual 3 nodes up and running. Peform the following copy from within the [secrets](secrets) directory:

```bash
➜ docker-machine scp -r . docker@node1:~/
```

The docker-compose file includes a secrets declaration:

```yml
version: "3.1"

services:
  psql:
    image: postgres
    secrets:
      - psql_user
      - psql_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/psql_password
      POSTGRES_USER_FILE: /run/secrets/psql_user

secrets:
  psql_user:
    file: ./psql_user.txt
  psql_password:
    file: ./psql_password.txt

```

Deploy on node1:

```bash
docker@node1:~$ docker stack deploy -c docker-compose.yml mydb
Creating network mydb_default
Creating secret mydb_psql_user
Creating secret mydb_psql_password
Creating service mydb_psql
```

```bash
docker@node1:~$ docker secret ls
ID                          NAME
09jwaqr7r2eddy9k27wa9u9n7   mydb_psql_password
p5njfbhtmolukq3gu105hg5e1   mydb_psql_user
```

(Note the prefixing of the stack name, in this case **mydb**).

Finally remove everything - by removing the stack the secrets are also removed:

```bash
docker@node1:~$ docker stack rm mydb
Removing service mydb_psql
Removing secret mydb_psql_password
Removing secret mydb_psql_user
Removing network mydb_default
```


# Secrets with Local Docker Compose

Navigate to the [secrets](secrets) directory where we have a docker-compose file and secrets:

```bash
docker-backwards/courses/docker-mastery/docs/swarm/secrets
➜ ls -las
total 24
0 drwxr-xr-x   5 davidainslie  staff  160  3 Jan 22:27 .
0 drwxr-xr-x  13 davidainslie  staff  416  6 Jan 21:22 ..
8 -rw-r--r--   1 davidainslie  staff  326  3 Jan 22:35 docker-compose.yml
8 -rw-r--r--   1 davidainslie  staff   13  3 Jan 22:27 psql_password.txt
8 -rw-r--r--   1 davidainslie  staff    7  3 Jan 22:27 psql_user.txt
```

The [docker-compose](secrets/docker-compose.yml) file has:

```yaml
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

Will the secrets be available with a simple **docker-compose up**?

```bash
➜ docker-compose up -d
WARNING: The Docker Engine you're using is running in swarm mode.
Compose does not use swarm mode to deploy services to multiple nodes in a swarm. All containers will be scheduled on the current node.
To deploy your application across the swarm, use `docker stack deploy`.

Creating network "secrets_default" with the default driver
Pulling psql (postgres:)...
...
Creating secrets_psql_1 ... done
```

And the secrets....

```bash
➜ docker-compose exec psql cat /run/secrets/psql_user
dbuser
```


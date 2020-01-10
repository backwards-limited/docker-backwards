# Health Checks

Three container states:

- starting
- healthy
- unhealthy

## Health check Docker Run example

```bash
$ docker run \
    --health-cmd="curl -f localhost:9200/_cluster/health || false" \
    --health-interval=5s \
    --health-retries=3 \
    --health-timeout=2s \
    --health-start-period=15s \
    elasticsearch:2
```

## Health check Dockerfile examples

Options for **HEALTHCHECK** command:

- --interval=DURATION (default 30s)
- --timeout=DURATION (default 30s)
- --start-period=DURATION (default 0s)
- --retries=N (default 3)

Basic command using default options:

- HEALTHCHECK curl -f http://localhost || false

Custom options with the command:

- HEALTHCHECK --timeout=2s --interval=3s --retries=3 CMD curl -f http://localhost || exit 1

## Health check in Nginx Dockerfile example

```dockerfile
FROM nginx:1.13

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost || exit 1
```

## Health check in postgres Dockerfile example

Within a container you may have CLI tools to use (instead of needing to curl some endpoint) e.g. postgres has **pg_isready** which simply indicates that a client can connect to postgres:

```dockerfile
FROM postgres

# Specify real user with -U to prevent errors in log
HEALTHCHECK --interval=5s --timeout=3s CMD pg_isready -U postgres || exit 1
```

## Health check in Compose/Stack file example

```yaml
version: "2.1" # The minimum for health checks

services:
  web:
    image: nginx
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 1m30s
      timeout: 10s
      retries: 3
      start_period: 1m # The minimum version needs to be 3.4
```

## Try it out on the command line

```bash
➜ docker container run --name p1 -d postgres
0d783d64df1f579b9f78c6c093a569b6c5365012d4b94f21410712062f939755
```

```bash
➜ docker container ls
CONTAINER ID   IMAGE      COMMAND                  STATUS           PORTS         NAMES
0d783d64df1f   postgres   "docker-entrypoint.s…"   Up 27 seconds    5432/tcp      p1
```

Run another postgres but with health checking:

```bash
➜ docker container run --name p2 -d --health-cmd="pg_isready -U postgres || exit 1" postgres
871627790e6977c9ad4731b5dae3900a680a1184d062dae54aefc76f441ae2d0
```

```bash
➜ docker container ls
CONTAINER ID    IMAGE       CREATED           STATUS                    PORTS         NAMES
871627790e69    postgres    35 seconds ago    Up 33 seconds (healthy)   5432/tcp      p2
0d783d64df1f    postgres    4 minutes ago     Up 4 minutes              5432/tcp      p1
```

Do the same for **service**:

```bash
➜ docker service create --name p1 postgres
mlkbd8babofg0ouqvzbp09sab
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
```

and with health checking where it may look like the start up has stalled, but it simply waits for the default of 30 seconds in a *starting* state until the health check has occurred and all is fine to switch over to *running*:

```bash
➜ docker service create --name p2 --health-cmd="pg_isready -U postgres || exit 1" postgres
gym3a8rpe7sfy23ny8j80bxpb
overall progress: 0 out of 1 tasks
1/1: starting  [============================================>      ]
```

i.e. after the default 30 seconds:

```bash
➜ docker service create --name p2 --health-cmd="pg_isready -U postgres || exit 1" postgres
gym3a8rpe7sfy23ny8j80bxpb
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
```


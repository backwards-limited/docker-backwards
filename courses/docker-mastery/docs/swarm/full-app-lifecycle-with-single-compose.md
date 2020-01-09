# Full App Lifecycle with Single Compose

- Local **docker-compose up** development environment
- Remote **docker-compose up** CI environment
- Remote **docker stack deploy** production environment

We'll be working in the [lifecycle](lifecycle) directory.

We have the default **docker-compose.yml** and the override **docker-compose.override.yml** along with two environment specific compose files **docker-compose.test.yml** and **docker-compose.prod.yml**.

## Dev

If we run the standard docker-compose up command, the default is used and the override automatically overrides:

```bash
docker-backwards/courses/docker-mastery/docs/swarm/lifecycle
➜ docker-compose up -d
Creating lifecycle_postgres_1 ... done
Creating lifecycle_drupal_1   ... done
```

To prove that the overrides occurred (which declared volumes) let's inspect the drupal container:

```bash
➜ docker container inspect lifecycle_drupal_1
[
    {
        ...
        "Mounts": [
            {
                "Type": "volume",
                "Name": "lifecycle_drupal-modules",
                "Source": "/var/lib/docker/volumes/lifecycle_drupal-modules/_data",
                "Destination": "/var/www/html/modules",
                "Driver": "local",
                "Mode": "rw",
                "RW": true,
                "Propagation": ""
            },
            {
                "Type": "volume",
                "Name": "lifecycle_drupal-profiles",
                "Source": "/var/lib/docker/volumes/lifecycle_drupal-profiles/_data",
                "Destination": "/var/www/html/profiles",
                "Driver": "local",
                "Mode": "rw",
                "RW": true,
                "Propagation": ""
            },
            ...
        ],
        ...
    }
]
```

```bash
➜ docker-compose down
Stopping lifecycle_drupal_1   ... done
Stopping lifecycle_postgres_1 ... done
Removing lifecycle_drupal_1   ... done
Removing lifecycle_postgres_1 ... done
Removing network lifecycle_default
```

## Test

On our CI:

```bash
➜ docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d
Creating network "lifecycle_default" with the default driver
Creating lifecycle_postgres_1 ... done
Creating lifecycle_drupal_1   ... done
```

```bash
➜ docker-compose down
Stopping lifecycle_postgres_1 ... done
Stopping lifecycle_drupal_1   ... done
Removing lifecycle_postgres_1 ... done
Removing lifecycle_drupal_1   ... done
Removing network lifecycle_default
```

## Prod

```bash
➜ docker-compose -f docker-compose.yml -f docker-compose.prod.yml config
```


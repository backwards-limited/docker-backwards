# Assignment 5 - Database Container Upgrade

Goals:

- Create **postgres** container with named volume **psql-data** using version **9.6.1**
- Check logs, stop container
- Create **postgres** container with same named volume **psql-data** using version **9.6.2**
- Check logs to validate

```bash
➜ docker container run -d --name psql-data -v psql-data:/var/lib/postgresql postgres:9.6.1

➜ docker volume ls
DRIVER              VOLUME NAME
local               psql-data
```

```bash
➜ docker container stop psql-data
```

```bash
➜ docker container run -d --name psql-data2 -v psql-data:/var/lib/postgresql postgres:9.6.2

➜ docker container ls -a
CONTAINER ID   IMAGE            STATUS                          PORTS               NAMES
1a87a0cb6c48   postgres:9.6.2   Up 32 seconds                   5432/tcp            psql-data2
503b2b161564   postgres:9.6.1   Exited (0) About a minute ago                       psql-data

➜ docker volume ls
DRIVER              VOLUME NAME
local               psql-data
```

```bash
➜ docker container rm -f $(docker container ls -aq)
```


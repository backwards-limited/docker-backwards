# Compose to Build

- Compose can build your custom images
- Will build them with **docker-compose up** if (and only if) not found in cache
- Rebuild with **docker-compose build**
- There is also the convenient **docker-compose up --build**

Run [docker-compose](../../docker-compose-files/1/docker-compose.yml):

```bash
docker-backwards/courses/docker-mastery/docker-compose-files/1
➜ docker-compose up
```

```bash
➜ docker image ls
REPOSITORY               TAG                 IMAGE ID            CREATED              SIZE
1_proxy                  latest              034d50ffb51f        About a minute ago   109MB
```

```bash
docker-backwards/courses/docker-mastery/docker-compose-files/1
➜ docker-compose down --rmi local
Stopping 1_web_1   ... done
Stopping 1_proxy_1 ... done
Removing 1_web_1   ... done
Removing 1_proxy_1 ... done
Removing network 1_default
Removing image 1_proxy
```

Note the last line; removing the image:

```bash
➜ docker image ls
REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
```


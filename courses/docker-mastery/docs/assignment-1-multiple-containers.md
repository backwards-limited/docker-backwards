# Assignment 1 - Multiple Containers

Goals:

- Run nginx, mysql and httpd (apache) server

```bash
➜ docker container run --name mysql -d -p 3306:3306 -e MYSQL_RANDOM_ROOT_PASSWORD=yes mysql
d51b873dfe3688af33203d1837502238cad1034ec66ff9d8e78f82fba07f9441

➜ docker container run --name httpd -d -p 8080:80 httpd
6da11aefbab3b7d8cd4cc7a7c5048add2869d84c603289073fea4d5d9f1c0f26

➜ docker container run --name nginx -d -p 80:80 nginx
bdd272bd8eb1c758ad1f0249147dfa1253cc1cb10e9e275af09f0eb74817b78a
```

```bash
➜ docker container logs mysql
Initializing database
...
GENERATED ROOT PASSWORD: rohSheish5OoXae9eexoochaileiShai
...
2019-09-29T19:28:46.361793Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.17'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL
...
```

Note the randomly generated MySql password.

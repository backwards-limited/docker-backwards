# Service Updates

Examples:

- Update image used to a newer version e.g.

  ```bash
  docker service update --image myapp:1.0.1 <service name>
  ```

- Adding an environment variable and remove a port e.g.

  ```bash
  docker service update --env-add NODE_ENV=production --publish-rm 8080
  ```

- Change number of replicas of two services e.g.

  ```bash
  docker service scale web=8 api=6
  ```

So let's start a service and trying updating:

```bash
➜ docker service create -p 8088:80 --name web nginx:1.13.7
qkbf7omt84nw01l4ctqzvz38r
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service converged
```

```bash
➜ docker service ls
ID             NAME        MODE           REPLICAS      IMAGE            PORTS
qkbf7omt84nw   web         replicated     1/1           nginx:1.13.7     *:8088->80/tcp
```

Let's **scale up**:

```bash
➜ docker service scale web=5
web scaled to 5
overall progress: 5 out of 5 tasks
1/5: running   [==================================================>]
2/5: running   [==================================================>]
3/5: running   [==================================================>]
4/5: running   [==================================================>]
5/5: running   [==================================================>]
verify: Service converged
```

Let's do a **rolling update** by changing the image version:

```bash
➜ docker service update --image nginx:1.13.6 web
web
overall progress: 5 out of 5 tasks
1/5: running   [==================================================>]
2/5: running   [==================================================>]
3/5: running   [==================================================>]
4/5: running   [==================================================>]
5/5: running   [==================================================>]
verify: Service converged
```

Now let's change a **port by removing and adding** a new one:

```bash
➜ docker service update --publish-rm 8088 --publish-add 9090:80 web
web
overall progress: 5 out of 5 tasks
1/5: running   [==================================================>]
2/5: running   [==================================================>]
3/5: running   [==================================================>]
4/5: running   [==================================================>]
5/5: running   [==================================================>]
verify: Service converged
```

**Remember to clean up:**

```bash
➜ docker service rm web
web
```


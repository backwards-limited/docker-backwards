# Security

See [Bret Fisher Security](https://github.com/BretFisher/ama/issues/17).

## Docker Bench

Run [Docker Bench](https://github.com/docker/docker-bench-security) which is a script that checks for dozens of common best-practices around deploying Docker containers in production. E.g.

```
➜ docker run -it --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /etc:/etc:ro \
    -v /usr/bin/docker-containerd:/usr/bin/docker-containerd:ro \
    -v /usr/bin/docker-runc:/usr/bin/docker-runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --label docker_bench_security \
    docker/docker-bench-security
```

## Using USER in Dockerfiles to Avoid Running as Root

Set USER in Dockerfile and use where necessary. E.g. Base Node images create a user named **node** so we can set the USER to **node**:

```dockerfile
RUN mkdir /app && chown -R node:node /app

WORKDIR /app

USER node

COPY --chown=node:node package.json package-lock*.json ./

RUN npm install && npm cache clean --force

COPY --chown=node: node . .
```

## Code Repo and Image Scanning for CVE's

Github does some nice scanning but to scan your Docker images you can use [Trivy](https://github.com/aquasecurity/trivy) or [Microscanner](https://github.com/aquasecurity/microscanner).

E.g. after installing on Mac:

```bash
➜ brew install aquasecurity/trivy/trivy
```

We can perform a scan such as:

```bash
➜ trivy python:3.4-alpine
```

## Runtime Bad Behaviour Monitoring

[Sysdig Falco](https://sysdig.com/opensource/falco/) can be used to detect **suspicious** behaviour of a running container - there is a demo on their website.

## Footnote

Control Groups (c-groups) define the resources of a container such as the amount of memory.
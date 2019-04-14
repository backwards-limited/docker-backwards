# Useful Commands

## Docker Commands 

```bash
Build image:
docker build .

Build & Tag:
docker build -t <user>/k8s-demo:latest .

Tag image:
docker tag imageid <user>/k8s-demo

Push image:
docker push <user>/k8s-demo

List images:
docker images

List all containers:
docker ps -a
```
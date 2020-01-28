# Exposing Kubernetes Ports

- A **service** is a stable address for pod(s)
- If we want to connect to pod(s) we need a **service**
- CoreDNS allows us to resolve services by name
- There are different types of services:
  - **ClusterIP** (default)
    - Single internal virtual IP allocated
    - Only reachable from within cluster (nodes and pods)
    - Pods can reach service on apps port number
  - **NodePort**
    - High port allocated on each node
    - Port is open on every node's IP
    - Anyone can connect (if they can reach node)
    - Other pods need to be updated to this port
  - **LoadBalancer** (mainly for cloud)
    - Controls LB endpoint external to the cluster
    - Only available when infrastructure provider gives you a LB (e.g. AWS ELB etc.)
    - Creates NodePort & ClusterIP services; tells LB to send to NodePort
  - **ExternalName**
    - Adds CNAME DNS record to CoreDNS only
    - Not used for pods, but for giving pods a DNS name to use for something outside Kubernetes
  - **Ingress**
    - Specifically designed for HTTP traffic

## Creating a ClusterIP Service

We will **watch** what we are doing from a separate **shell** (where we show output having already run the second shell):

```bash
➜ kc get pods -w
NAME                       READY     STATUS    RESTARTS   AGE
httpenv-7cc9888d59-8lgmv   0/1       Pending   0          0s
httpenv-7cc9888d59-8lgmv   0/1       Pending   0         0s
httpenv-7cc9888d59-8lgmv   0/1       ContainerCreating   0         0s
httpenv-7cc9888d59-8lgmv   1/1       Running   0         5s
```

From a second shell, start a http server (an app with **get** endpoint that returns environment variables):

```bash
➜ kc create deployment httpenv --image=bretfisher/httpenv
deployment "httpenv" created
```

Scale it up to 5 replicas:

```bash
➜ kc scale deploy/httpenv --replicas=5
deployment "httpenv" scaled
```

Let's see all those changes now:

```bash
➜ kc get pods -w
NAME                       READY     STATUS    RESTARTS   AGE
httpenv-7cc9888d59-8lgmv   0/1       Pending   0          0s
httpenv-7cc9888d59-8lgmv   0/1       Pending   0         0s
httpenv-7cc9888d59-8lgmv   0/1       ContainerCreating   0         0s
httpenv-7cc9888d59-8lgmv   1/1       Running   0         5s
httpenv-7cc9888d59-24mkv   0/1       Pending   0         0s
httpenv-7cc9888d59-vsw52   0/1       Pending   0         0s
httpenv-7cc9888d59-nr6sq   0/1       Pending   0         0s
httpenv-7cc9888d59-24mkv   0/1       Pending   0         0s
httpenv-7cc9888d59-vsw52   0/1       Pending   0         0s
httpenv-7cc9888d59-tvx6p   0/1       Pending   0         1s
httpenv-7cc9888d59-nr6sq   0/1       Pending   0         1s
httpenv-7cc9888d59-tvx6p   0/1       Pending   0         1s
httpenv-7cc9888d59-24mkv   0/1       ContainerCreating   0         1s
httpenv-7cc9888d59-vsw52   0/1       ContainerCreating   0         1s
httpenv-7cc9888d59-nr6sq   0/1       ContainerCreating   0         2s
httpenv-7cc9888d59-tvx6p   0/1       ContainerCreating   0         2s
httpenv-7cc9888d59-24mkv   1/1       Running   0         11s
httpenv-7cc9888d59-vsw52   1/1       Running   0         12s
httpenv-7cc9888d59-nr6sq   1/1       Running   0         13s
httpenv-7cc9888d59-tvx6p   1/1       Running   0         16s
```

Create a ClusterIP service (default):

```bash
➜ kc expose deploy/httpenv --port 8888
service "httpenv" exposed
```

```bash
➜ kc get service
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
httpenv      ClusterIP   10.110.184.235   <none>        8888/TCP   36s
```

Remember this IP is cluster internal only - how do we curl it?

We need to run another pod, so we can jump onto it and then perform a curl:

```bash
➜ kc run --generator run-pod/v1 tmp-shell --rm -it --image bretfisher/netshoot -- bash
bash-5.0#
```

And our **watch** shell shows the new pod named **tmp-shell** i.e. we have used a Kubernetes **generator** to only create a pod avoiding unnecessary Deployment and ReplicaSet in this case:

```bash
➜ kc get pods -w
NAME                       READY     STATUS    RESTARTS   AGE
...
tmp-shell   0/1       Pending   0         0s
tmp-shell   0/1       Pending   0         0s
tmp-shell   0/1       ContainerCreating   0         0s
tmp-shell   1/1       Running   0         34s
```

Now, the **service name** becomes part of the **DNS name** for this service:

```bash
bash-5.0# curl httpenv:8888
{ 
   "HOME":"/root",
   "HOSTNAME":"httpenv-7cc9888d59-24mkv",
   "KUBERNETES_PORT":"tcp://10.96.0.1:443",
   "KUBERNETES_PORT_443_TCP":"tcp://10.96.0.1:443",
   "KUBERNETES_PORT_443_TCP_ADDR":"10.96.0.1",
   "KUBERNETES_PORT_443_TCP_PORT":"443",
   "KUBERNETES_PORT_443_TCP_PROTO":"tcp",
   "KUBERNETES_SERVICE_HOST":"10.96.0.1",
   "KUBERNETES_SERVICE_PORT":"443",
   "KUBERNETES_SERVICE_PORT_HTTPS":"443",
   "PATH":"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}
```

If you are on **Linux** host:

```bash
$ curl [ip of service]:8888
```

## Create a NodePort Service

Let's just see what we currently have from above:

```bash
➜ kc get all
NAME             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/httpenv   5         5         5            5           26m

NAME                    DESIRED   CURRENT   READY     AGE
rs/httpenv-7cc9888d59   5         5         5         26m

NAME                          READY     STATUS    RESTARTS   AGE
po/httpenv-7cc9888d59-24mkv   1/1       Running   0          22m
po/httpenv-7cc9888d59-8lgmv   1/1       Running   0          26m
po/httpenv-7cc9888d59-nr6sq   1/1       Running   0          22m
po/httpenv-7cc9888d59-tvx6p   1/1       Running   0          22m
po/httpenv-7cc9888d59-vsw52   1/1       Running   0          22m

NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
svc/httpenv      ClusterIP   10.110.184.235   <none>        8888/TCP   20m
```

Let's expose a NodePort so we can access it via the **host IP** (including **localhost** on macOS, Linux, Windows):

```bash
➜ kc expose deploy/httpenv --port 8888 --name httpenv-np --type NodePort
service "httpenv-np" exposed
```

```bash
➜ kc get services
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
httpenv      ClusterIP   10.110.184.235   <none>        8888/TCP         24m
httpenv-np   NodePort    10.98.116.121    <none>        8888:32141/TCP   27s
```

Now the ports are reversed when compared to Docker e.g.

8888:32141

where 8888 is inside the cluster, whereas 32141 in on your cluster nodes exposed to the outside world.

Also note, that a NodePort service also creates a ClusterIP. The 3 service types are additive, where each one creates the ones above it:

- ClusterIP
- NodePort
- LoadBalancer

```bash
➜ curl localhost:32141
{ 
   "HOME":"/root",
   "HOSTNAME":"httpenv-7cc9888d59-nr6sq",
   "KUBERNETES_PORT":"tcp://10.96.0.1:443",
   "KUBERNETES_PORT_443_TCP":"tcp://10.96.0.1:443",
   "KUBERNETES_PORT_443_TCP_ADDR":"10.96.0.1",
   "KUBERNETES_PORT_443_TCP_PORT":"443",
   "KUBERNETES_PORT_443_TCP_PROTO":"tcp",
   "KUBERNETES_SERVICE_HOST":"10.96.0.1",
   "KUBERNETES_SERVICE_PORT":"443",
   "KUBERNETES_SERVICE_PORT_HTTPS":"443",
   "PATH":"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}
```

## Create a LoadBalancer Service

If you are on **Docker Desktop**, it provides a built-in LoadBalancer that publishes the **--port** on **localhost**:

```bash
➜ kc expose deploy/httpenv --port 8888 --name httpenv-lb --type LoadBalancer
service "httpenv-lb" exposed
```

```bash
➜ kc get services
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
httpenv      ClusterIP      10.110.184.235   <none>        8888/TCP         37m
httpenv-np   NodePort       10.98.116.121    <none>        8888:32141/TCP   14m
httpenv-lb   LoadBalancer   10.102.247.102   localhost     8888:31250/TCP   25s
```

```bash
➜ curl localhost:8888
{ 
   "HOME":"/root",
   "HOSTNAME":"httpenv-7cc9888d59-nr6sq",
   "KUBERNETES_PORT":"tcp://10.96.0.1:443",
   "KUBERNETES_PORT_443_TCP":"tcp://10.96.0.1:443",
   "KUBERNETES_PORT_443_TCP_ADDR":"10.96.0.1",
   "KUBERNETES_PORT_443_TCP_PORT":"443",
   "KUBERNETES_PORT_443_TCP_PROTO":"tcp",
   "KUBERNETES_SERVICE_HOST":"10.96.0.1",
   "KUBERNETES_SERVICE_PORT":"443",
   "KUBERNETES_SERVICE_PORT_HTTPS":"443",
   "PATH":"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}
```

Don't forget to cleanup:

```bash
➜ kc delete svc/httpenv svc/httpenv-np svc/httpenv-lb deploy/httpenv
service "httpenv" deleted
service "httpenv-np" deleted
service "httpenv-lb" deleted
deployment "httpenv" deleted
```

## Kubernetes Services DNS

Using hostname to access service:

```bash
➜ curl <hostname>
```

Services also have a FQDN:

```bash
➜ curl <hostname>.<namespace>.svc.cluster.local
```


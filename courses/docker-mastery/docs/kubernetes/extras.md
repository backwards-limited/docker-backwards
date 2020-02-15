# Kubernetes Extras

## Storage

Creating and connecting Volumes - two types:

- Volumes
  - Tied to lifecycle of a Pod
  - All containers in a single Pod can share them
- PersistentVolumes
  - Created at the cluster level; outlives a Pod
  - Separates storage config from Pod using it
  - Multiple Pods can share them

## Namespace

```bash
➜ kc get all --all-namespaces
NAMESPACE     NAME                                         READY   STATUS    RESTARTS   AGE
docker        pod/compose-7b7c5cbbcc-6xdg6                 1/1     Running   0          24d
docker        pod/compose-api-dbbf7c5db-lvxvh              1/1     Running   0          24d
kube-system   pod/coredns-5c98db65d4-cbcx8                 1/1     Running   1          24d
kube-system   pod/coredns-5c98db65d4-t97k4                 1/1     Running   1          24d
kube-system   pod/etcd-docker-desktop                      1/1     Running   0          24d
kube-system   pod/kube-apiserver-docker-desktop            1/1     Running   0          24d
kube-system   pod/kube-controller-manager-docker-desktop   1/1     Running   0          24d
kube-system   pod/kube-proxy-fmv92                         1/1     Running   0          24d
kube-system   pod/kube-scheduler-docker-desktop            1/1     Running   0          24d

NAMESPACE     NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
default       service/kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP
docker        service/compose-api   ClusterIP   10.107.87.182   <none>        443/TCP
kube-system   service/kube-dns      ClusterIP   10.96.0.10      <none>   53/UDP,53/TCP,9153/TCP

NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE
kube-system   daemonset.apps/kube-proxy   1         1         1       1            1           

NAMESPACE     NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
docker        deployment.apps/compose       1/1     1            1           24d
docker        deployment.apps/compose-api   1/1     1            1           24d
kube-system   deployment.apps/coredns       2/2     2            2           24d

NAMESPACE     NAME                                    DESIRED   CURRENT   READY   AGE
docker        replicaset.apps/compose-7b7c5cbbcc      1         1         1       24d
docker        replicaset.apps/compose-api-dbbf7c5db   1         1         1       24d
kube-system   replicaset.apps/coredns-5c98db65d4      2         2         2       24d
```

## Context

```bash
➜ kc config get-contexts
CURRENT   NAME                   CLUSTER               AUTHINFO            NAMESPACE
          backwards.tech         backwards.tech        backwards.tech
          dev-induction          dsp-dev               dsp-dev             dev-induction
*         docker-desktop         docker-desktop        docker-desktop
          docker-for-desktop     docker-desktop        docker-desktop
          lev-web-preprod        dsp-dev               dsp-dev             lev-web-preprod
          local                  default-cluster       default-admin
          minikube               minikube              minikube
```




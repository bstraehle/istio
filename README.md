```
istioctl install --set profile=demo  
kubectl label namespace default istio-injection=enabled  
```

\# create kubernetes deployments and services, see https://github.com/bstraehle/kubernetes.git  

```
kubectl apply -f istio.custom.yaml  
kubectl get pods -o=custom-columns="images:spec.containers[\*].image"  
istioctl x describe pod <pod>  
```

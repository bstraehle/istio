- Create GKE, EKS, or AKS cluster, see https://github.com/bstraehle/kubernetes.git  
- Download Istio:  
```
curl -L https://istio.io/downloadIstio | sh -  
```
- Install Istio:  
```
cd istio-<x>.<y>.<z>  
istioctl install --set profile=demo  
```
- Instruct Istio to automatically inject Envoy sidecar proxies:  
```
kubectl label namespace default istio-injection=enabled  
```
- Create Kubernetes deployments and services, see https://github.com/bstraehle/kubernetes.git  
- Apply cluster-wide mTLS:  
```
git clone https://github.com/bstraehle/istio.git  
cd istio  
kubectl apply -f istio.custom.yaml  
```
- Inspect cluster-wide mTLS:  
```
kubectl get pods -o=custom-columns="images:spec.containers[*].image"  
kubectl get pods  
istioctl x describe pod <pod> | grep "TLS"  
```

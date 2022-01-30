- Create GKE, EKS, or AKS cluster, see https://github.com/bstraehle/kubernetes.git  
- Download and install Istio:  
```
curl -L https://istio.io/downloadIstio | sh -  
cd istio-<x>.<y>.<z>  
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo  
```
- Instruct Istio to automatically inject Envoy sidecar proxies:  
```
kubectl label namespace default istio-injection=enabled  
```
- Create Kubernetes deployments and services, see https://github.com/bstraehle/kubernetes.git  
- Apply Istio security, traffic management, and observability:  
```
git clone https://github.com/bstraehle/istio.git  
cd istio  
kubectl apply -f istio.custom.yaml  
```
- Inspect Istio security, traffic management, observability:  
```
kubectl get pods -o=custom-columns="images:spec.containers[*].image"  
kubectl get pods  
istioctl x describe pod <pod>  
```

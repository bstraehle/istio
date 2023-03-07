# Istio  

Istio is an open source service mesh that layers transparently onto existing distributed applications.

## Example  

- Create EKS, AKS, or GKE cluster, see https://github.com/bstraehle/kubernetes  
- Download and install Istio:  
```
curl -L https://istio.io/downloadIstio | sh -  
cd istio-*  
export PATH=$PWD/bin:$PATH  
istioctl install --set profile=demo -y  
```
- Instruct Istio to automatically inject Envoy sidecar proxies:  
```
kubectl label namespace default istio-injection=enabled  
```
- Create Kubernetes deployments and services, see https://github.com/bstraehle/kubernetes  
- Apply Istio security, traffic management, and observability:  
```
git clone https://github.com/bstraehle/istio.git  
cd istio  
kubectl apply -f istio.custom.yaml  
```
- Inspect Istio security, traffic management, observability:  
```
kubectl get pods  
kubectl get pods -o=custom-columns="images:spec.containers[*].image" | grep istio  
istioctl x describe service mvc-app-service | grep "TLS Mode"  
istioctl x describe service rest-api-service | grep "TLS Mode"  
```
- Inspect Istio ingress gateway:  
```
kubectl get services istio-ingressgateway -n istio-system  
```
```
<external-ip>  
```

## Resources  

- Book: <a href="https://www.amazon.com/Istio-Running-Service-Connect-Control/dp/1492043788/ref=sr_1_5">O’Reilly: Istio Up & Running</a>  

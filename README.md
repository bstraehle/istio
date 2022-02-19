Create GKE, EKS, or AKS cluster, see https://github.com/bstraehle/kubernetes.git#readme  

Download and install Istio:  
```
curl -L https://istio.io/downloadIstio | sh -  
cd istio-*  
istioctl install --set profile=demo  
```
Instruct Istio to automatically inject Envoy sidecar proxies:  
```
kubectl label namespace default istio-injection=enabled  
```
Create Kubernetes deployments and services, see https://github.com/bstraehle/kubernetes.git#readme  

Apply Istio security, traffic management, and observability:  
```
git clone https://github.com/bstraehle/istio.git  
cd istio  
kubectl apply -f istio.custom.yaml  
```
Inspect Istio security, traffic management, observability:  
```
kubectl get pods -o=custom-columns="images:spec.containers[*].image"  
kubectl get pods  
istioctl x describe service mvc-app-service  
```
Inspect Istio ingress gateway:  
```
kubectl get services istio-ingressgateway -n istio-system  
```
URL:  
```
<external-ip>  
```
Useful Links:  
- Book: <a href="https://www.amazon.com/Istio-Running-Service-Connect-Control/dp/1492043788/ref=sr_1_5">O’Reilly: Istio Up & Running - Using a Service Mesh to Connect, Secure, Control, and Observe</a>  

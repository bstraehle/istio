# Istio

[![CI](https://github.com/bstraehle/istio/actions/workflows/ci.yml/badge.svg)](https://github.com/bstraehle/istio/actions/workflows/ci.yml)

[Istio](https://istio.io/) is an open source service mesh that layers transparently onto existing distributed applications. This repo adds Istio security, traffic management, and observability to the demo apps deployed by [bstraehle/kubernetes](https://github.com/bstraehle/kubernetes).

## Table of Contents

1. [What Gets Applied](#1-what-gets-applied)
2. [Install Istio](#2-install-istio)
3. [Deploy the Apps into the Mesh](#3-deploy-the-apps-into-the-mesh)
4. [Apply Istio Policies](#4-apply-istio-policies)
5. [Access and Inspect](#5-access-and-inspect)
6. [Clean Up](#6-clean-up)
7. [CI](#7-ci)
8. [Resources](#8-resources)

## 1. What Gets Applied

All resources go to the `demo` namespace ([`manifests/`](manifests)):

| File | Resources | Effect |
| --- | --- | --- |
| [`gateway.yaml`](manifests/gateway.yaml) | `Gateway`, `VirtualService` | Exposes `mvc-app-service` on port 80 of the Istio ingress gateway, with a 10s timeout and retries |
| [`peer-authentication.yaml`](manifests/peer-authentication.yaml) | `PeerAuthentication` | Requires mutual TLS (`STRICT`) for all traffic to workloads in the namespace |
| [`authorization-policies.yaml`](manifests/authorization-policies.yaml) | `AuthorizationPolicy` ×3 | Denies everything by default, then allows only *ingress gateway → mvc-app* and *mvc-app → rest-api* (`GET`/`POST`/`PUT`/`DELETE` on `/Demo` paths), by workload identity |

Traffic between sidecars uses Istio mTLS automatically, so no `DestinationRule` is needed.

## 2. Install Istio

Create an EKS, AKS, GKE, or kind cluster; see [bstraehle/kubernetes](https://github.com/bstraehle/kubernetes#2-create-a-cluster).

Download `istioctl` and install Istio with the demo profile and the [Istio CNI node agent](https://istio.io/latest/docs/setup/additional-setup/cni/):

```shell
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.32.0 sh -
export PATH=$PWD/istio-1.32.0/bin:$PATH

istioctl x precheck
istioctl install --set profile=demo --set components.cni.enabled=true -y
```

> Note: The `demo` namespace enforces the restricted Pod Security Standard. The Istio CNI agent replaces the privileged `istio-init` container that sidecar injection would otherwise add, so injected pods stay compliant. On GKE, follow the [GKE platform setup](https://istio.io/latest/docs/setup/platform-setup/gke/) first: the CNI agent runs as a `system-node-critical` pod, which GKE only allows outside `kube-system` with a matching ResourceQuota. Use a Standard cluster; Autopilot doesn't allow the privileged CNI agent.

## 3. Deploy the Apps into the Mesh

Deploy the apps, turn on automatic sidecar injection for the namespace, and restart the pods so they get Envoy sidecars:

```shell
git clone https://github.com/bstraehle/kubernetes.git
kubectl apply -k kubernetes/manifests

kubectl label namespace demo istio-injection=enabled
kubectl -n demo rollout restart deployment/rest-api deployment/mvc-app
kubectl -n demo rollout status deployment/rest-api
kubectl -n demo rollout status deployment/mvc-app
```

## 4. Apply Istio Policies

```shell
git clone https://github.com/bstraehle/istio.git
kubectl apply -k istio/manifests

istioctl analyze -n demo
```

## 5. Access and Inspect

Get the ingress gateway address:

```shell
kubectl -n istio-system get service istio-ingressgateway
```

Open `http://<EXTERNAL-IP>/` and choose **Demo**. On kind or any cluster without a load balancer:

```shell
kubectl -n istio-system port-forward service/istio-ingressgateway 8080:80
```

Then open http://localhost:8080.

Inspect sidecars, routing, and policies:

```shell
kubectl -n demo get pods -o custom-columns='POD:.metadata.name,CONTAINERS:.spec.containers[*].name,INIT:.spec.initContainers[*].name'
istioctl proxy-status
istioctl x describe service mvc-app-service -n demo
istioctl x authz check deployment/rest-api -n demo
```

Zero trust in action: a workload other than `mvc-app` gets `403 RBAC: access denied` from the API, and so does a client that bypasses the ingress gateway to call the MVC app. The API's Swagger UI is also not reachable inside the mesh, because only `/Demo` paths are allowed. Clients outside the mesh can't connect at all, because mTLS is `STRICT`.

Observability: the demo profile enables access logs (`kubectl -n demo logs deploy/mvc-app -c istio-proxy`). For dashboards, install the [Kiali, Prometheus, and Grafana addons](https://istio.io/latest/docs/ops/integrations/) from `istio-1.32.0/samples/addons`, then run `istioctl dashboard kiali`.

## 6. Clean Up

```shell
kubectl delete -k istio/manifests
kubectl delete -k kubernetes/manifests
istioctl uninstall --purge -y
kubectl delete namespace istio-system
```

## 7. CI

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs `istioctl analyze` on the rendered manifests together with those of [bstraehle/kubernetes](https://github.com/bstraehle/kubernetes). It then installs Istio on a kind cluster and checks allowed traffic through the ingress gateway, including `/Demo/List`, which goes from the MVC app through to the API. It also checks that a workload with another identity gets `403`. It runs on every push and pull request, and weekly.

## 8. Resources

- [Istio documentation](https://istio.io/latest/docs/)
- [Istio security best practices](https://istio.io/latest/docs/ops/best-practices/security/)
- Book: [O'Reilly: Istio Up & Running](https://www.amazon.com/Istio-Running-Service-Connect-Control/dp/1492043788)

# Pokémon Vitess Setup Example

This repository demonstrates how to set up a Vitess environment using Minikube for managing a Pokémon and Trainer database with vertical sharding.

---

## 🧱 Prerequisites

Make sure you have the following installed:

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Vitess Operator](https://github.com/vitessio/vitess-operator)
- `vtctldclient` installed and available in your PATH

---

## ⚙️ Setup Instructions

Follow these steps to bring up the Vitess cluster and apply vertical sharding:

### 1. Start Minikube
```bash
minikube start
kubectl create namespace suuexample
kubectl apply -f vitess_config/operator.yaml
kubectl apply -f vitess_config/initial_cluster.yaml
kubectl port-forward -n suuexample --address 127.0.0.1 \
"$(kubectl get service -n suuexample --selector="planetscale.com/component=vtctld" -o name | head -n1)" 15000 15999 &

kubectl port-forward -n suuexample --address 127.0.0.1 \
"$(kubectl get service -n suuexample --selector='planetscale.com/component=vtgate,!planetscale.com/cell' -o name | head -n1)" 15306:3306 &

kubectl port-forward -n suuexample --address 127.0.0.1 \
"$(kubectl get service -n suuexample --selector="planetscale.com/component=vtadmin" -o name | head -n1)" 14000:15000 14001:15001 &
kubectl apply -f vitess_config/vertical_sharding/vertical_sharding.yaml
./vitess_config/vertical_sharding/vertical_sharding.sh
vtctldclient MoveTables --workflow trainersAlone --target-keyspace trainers complete
```bash


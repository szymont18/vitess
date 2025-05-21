# Pokémon Vitess Setup

This repository demonstrates how to set up a Vitess environment using Minikube for managing a Pokémon and Trainer database with vertical sharding.

---

## 🧱 Prerequisites

Make sure you have the following installed:

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [mysql](https://dev.mysql.com/doc/mysql-getting-started/en/)
- `vtctldclient` installed and available in your PATH

---

## ⚙️ Setup Instructions

Follow these steps to bring up the Vitess cluster and apply vertical sharding:

### 1. Setup environment and cluster
```bash
minikube start
kubectl create namespace suuexample
kubectl apply -f vitess_config/operator.yaml
kubectl apply -f vitess_config/initial_cluster.yaml
```

### 2. Port forwarding
```bash
kubectl port-forward -n suuexample --address 127.0.0.1 \
"$(kubectl get service -n suuexample --selector="planetscale.com/component=vtctld" -o name | head -n1)" 15000 15999

kubectl port-forward -n suuexample --address 127.0.0.1 \
"$(kubectl get service -n suuexample --selector='planetscale.com/component=vtgate,!planetscale.com/cell' -o name | head -n1)" 15306:3306

kubectl port-forward -n suuexample --address 127.0.0.1 \
"$(kubectl get service -n suuexample --selector="planetscale.com/component=vtadmin" -o name | head -n1)" 14000:15000 14001:15001
```

### 3. Alias SQL and vtctldclient
```bash
alias mysql="mysql -h 127.0.0.1 -P 15306 -u user"
alias vtctldclient="vtctldclient --server localhost:15999 --alsologtostderr"
```

### 4. Create database and put initial data
```bash
vtctldclient ApplySchema --sql="$(cat vitess_config/sqls/initial_database.sql)" pokemondB
vtctldclient ApplyVSchema --vschema="$(cat vitess_config/sqls/initial_vschema.json)" pokemondB

mysql < vitess_config/sqls/initial_data.sql
```

### 5. Vertical sharding
```bash
kubectl apply -f vitess_config/vertical_sharding/vertical_sharding.yaml
./vitess_config/vertical_sharding/vertical_sharding.sh
vtctldclient MoveTables --workflow trainersAlone --target-keyspace trainers complete
```

### 6. Horizontal sharding
```bash
./vitess_config/horizontal_sharding/horizontal_sharding.sh
kubectl apply -f vitess_config/horizontal_sharding/horizontal_sharding.yaml
vtctldclient Reshard --workflow poke2poke --target-keyspace pokemondB create --source-shards '-' --target-shards '-80,80-'
```


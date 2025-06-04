# Demo shardingu w Vitess z OTel

Repozytorium demonstruje, jak skonfigurować środowisko Vitess przy użyciu AWS do zarządzania bazą danych z wykorzystaniem shardingu wertykalnego i horyzontalnego.

---

## 🧱 Wymagania wstępne

Upewnij się, że masz zainstalowane następujące narzędzia:


- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [mysql](https://dev.mysql.com/doc/mysql-getting-started/en/)
- [`vtctldclient`] installed and available in your PATH

---

# Jak odtworzyć projekt - krok po kroku

Sekcja ta ma za zadanie umożliwić innej osobie dokładne odtworzenie środowiska od zera, w tym instalacji narzędzi i ich konfiguracji. Przedstawia pełny „przepis” krok po kroku.

## setup minikube
```bash
minikube start --cpus=8 --memory=4096 --disk-size=50g
```

## setup kubectl

```bash
kubectl create namespace example
kubectl create namespace telemetry
cd kube
kubectl apply -f operator.yaml # czekac az wstanie
kubectl apply -f 101_initial_cluster.yaml # czekac az wstanie
```

## seedowanie bazy + portforward
```bash
./pf.sh &
alias mysql="mysql -h 127.0.0.1 -P 15306 -u user"
alias vtctldclient="vtctldclient --server localhost:15999 --alsologtostderr"
vtctldclient ApplySchema --sql="$(cat create_commerce_schema.sql)" commerce
vtctldclient ApplyVSchema --vschema="$(cat vschema_commerce_initial.json)" commerce
```

## telemetry
```bash
cd otel
find . -name '*.yaml' -exec kubectl apply -f {} \; # zaaplikowanie kazdego pliku yaml
kubectl port-forward svc/grafana 3000:80 -n telemetry # port forwarding grafany
```

## setup grafany
Connections > Data Source > Add new data source > Prometheus > w url trzeba wpisac http://prometheus.telemetry.svc.cluster.local:9090 i klinkac "Save & test"

## dashboard
tutaj to zdjecie konfiguracji - nie potrafie powiedziec z glowy jak sie dodaje zdjecia

## stress test
```bash
# trzeba byc w ./kube
for i in {1..10000}; do mysql --table < select_commerce_data.sql > /dev/null; done
```

# Vitess Demo

### 1. Wprowadzenie
Celem projektu jest przedstawienie studium przypadku systemu Vitess – open-sourcowej
platformy służącej do skalowania baz danych MySQL w środowiskach chmurowych i rozproszonych. Vitess został stworzony przez YouTube jako odpowiedź na rosnące potrzeby skalowalności i dostępności danych w dużych systemach produkcyjnych, gdzie tradycyjne podejście
do baz danych relacyjnych okazywało się niewystarczające.
Vitess łączy w sobie zalety tradycyjnych baz danych (jak ACID i SQL) z elastycznością architektur opartych na mikrousługach i kontenerach. Umożliwia m.in. sharding, replikację, przełączanie awaryjne oraz zarządzanie schematem w sposób spójny i zautomatyzowany. Dzięki
integracji z Kubernetesem i innymi narzędziami cloud-native, Vitess idealnie wpisuje się w
potrzeby nowoczesnych, skalowalnych aplikacji.

Przykładowe firmy i usługi, które korzystają z technologii Vitess, to:
- YouTube – gdzie projekt się narodził, jako rozwiązanie problemów skalowalności bazy
danych,
- Slack – dla obsługi ogromnej ilości wiadomości i użytkowników w czasie rzeczywistym,
- GitHub – do obsługi skomplikowanej infrastruktury danych przy zachowaniu wysokiej
dostępności i wydajności.

### 2. Wstęp teoretyczny
Vitess składa się z kilku kluczowych komponentów, które współpracują, aby zapewnić wydajność, skalowalność oraz wysoką dostępność baz danych. Oto najważniejsze z nich:

- Vtorc – odpowiada za automatyczne zarządzanie topologią replikacji MySQL oraz wykrywanie i reagowanie na awarie w klastrze bazodanowym.

- VTGate – brama (proxy) łącząca aplikacje z systemem Vitess. Odpowiada za przyjmowanie zapytań SQL od klientów i ich kierowanie do odpowiednich shardów i replik.

- VTTablet – serwis działający obok instancji MySQL w każdej replice. Odpowiada między innymi za zarządzanie instancją MySQL oraz odpowiadanie na zapytania przychodzące z VTGate.

- vtctld – interfejs administracyjny służący do zarządzania klastrem Vitess. Umożliwia między innymi monitorowanie stanu klastra czy tworzenie nowych shardów oraz replik.

- Shardy – instancje baz danych, do których kierowane są zapytania. Każdy z nich posiada własną instancję VTTablet, która jest pośrednikiem w komunikacji między instancją bazy danych a VTGate.

Architektura tej technologii wygląda następująco (obrazek wzięty z oficjalnej dokumentacji Vitess).

![Opis alternatywny](img/architecture.png)

### 3. Opis koncepcji

W ramach początkowej wizji projektu zaplanowano oraz zaprojektowano 2 scenariusze, koncentrujące się na dwóch modelach shardingu: horyzontalnym oraz wertykalnym, z wykorzystaniem replikacji i komponentów systemu Vitess, takich jak VTGate i VTTablet.

Ze względu na potrzeby sprzętowe przewyzszające dostępne zasody (zarówno prywatne w postaci pamięci własnych maszyn jak i wirtualne w postaci chmury AWS) konieczna była rezygnacja z zaplanowanych scenariuszy skalowania i decyzja o zmianie scenariusza:

#### Scenariusz testu

W zaprezentowanym scenariuszu skupiliśmy się na pokazaniu działania systemu Vitess przez wywoływanie queries do bazy danych oraz obserwacji zachowania systemu z pomocą narzędzie OTel, Prometeus i Grafana.

Przebieg:
- Uzytkownik posiada dostęp do bazy danych właściwie przygotowanej do działania według kroków w punktach 6-7
- Uzytkownik wykonuje wielokrotnie zapytania do bazy danych obciązając tym samym system, np. `SELECT * FROM customer`, `SELECT * FROM product` czy `SELECT * FROM corder` - konieczne jest przeprowadzenie zapytań w bardzo niewielkim odstępie czasowym tak, zeby odpowiednio dociązyć system
- Obserwujemy na Grafanie zwiększone wykorzystanie CPU w momencie wywołania zapytań


### 4 Architektura rozwiązania
W projekcie zaprezentowano uruchomienie klastra Vitess w środowisku Kubernetes przy
użyciu operatora Vitess.
Cała architektura opiera się na kilku warstwach:

- Kubernetes – jako platforma orkiestracyjna do uruchamiania i skalowania usług kontenerowych.

- Vitess Operator – komponent zarządzający zasobami Vitess w klastrze K8s (shardy, replikacje, VTGate, VTTablet, itd.).

- MySQL – backend bazodanowy obsługiwany przez Vitess.

- OTel Collector -  modułowy komponent zbierający, przetwarzający i eksportujący dane telemetryczne (logi, metryki, ślady) zgodnie ze standardem OpenTelemetry

- Prometheus - system monitorowania i alertowania, który zbiera metryki z aplikacji i usług za pomocą modelu pull i przechowuje je w swojej bazie czasowej.

- Grafana – system do wizualizacji metryk.

Architektura została rozbudowana o integrację z narzędziami do obserwowalności (observability), dzięki czemu możliwe było przeanalizowanie rozkładu zapytań i obciążeń w czasie rzeczywistym.
![Opis alternatywny](img/arch.jpg)

### 5  Konfiguracja środowiska

Środowisko wykonawcze projektu zostało uruchomione lokalnie przy użyciu Minikube — lekkiej wersji klastra Kubernetes przeznaczonej do uruchamiania na pojedynczej maszynie.
W celu zapewnienia odpowiednich zasobów dla komponentów Vitessa, klaster został zainicjowany za pomocą następującej komendy:
```bash
minikube start --cpus=8 --memory=4096 --disk-size=50g
```
Konfiguracja ta przydziela klastrowi 8 wirtualnych CPU, 4 GB pamięci RAM oraz 50 GB przestrzeni dyskowej.

### 6 Metody instalacji
Aby móc korzystać z wyżej opisanego demo, należy wcześniej zainstalować następujące narzędzia:

- kubectl v1.30.2 – narzędzie wiersza poleceń służące do zarządzania klastrami Kubernetes. Umożliwia wykonywanie operacji takich jak wdrażanie aplikacji, monitorowanie zasobów oraz diagnozowanie problemów w środowisku Kubernetes.

- mysql v5.7 – narzędzie wiersza poleceń umożliwiające łączenie się z serwerem MySQL, wykonywanie zapytań SQL oraz zarządzanie bazami danych. Jest przydatne do testowania połączeń, przeglądania danych i administracji bazą.

- vtctldclient – narzędzie wiersza poleceń służące do komunikacji z komponentem vtctld w systemie Vitess. Umożliwia zarządzanie shardami, keyspace’ami i innymi elementami klastra Vitess.

- Docker – platforma do tworzenia, uruchamiania i zarządzania kontenerami. W projekcie wykorzystywana jest do budowania obrazów oraz uruchamiania komponentów systemu Vitess, Otel oraz Grafana w środowisku kontenerowym.

- Minikube – narzędzie umożliwiające lokalne uruchomienie klastra Kubernetes. Używane w tym projekcie jako środowisko testowe dla Vitessa.

### 7. Jak odtworzyć projekt krok po kroku
Sekcja ta ma za zadanie umożliwić innej osobie dokładne odtworzenie środowiska od zera,
w tym instalacji narzędzi i ich konfiguracji. Przedstawia pełny „przepis” krok po kroku.

#### Setup minikube
```bash
minikube start --cpus=8 --memory=4096 --disk-size=50g
```

#### Setup namespace
```bash
kubectl create namespace example
kubectl create namespace telemetry
```

#### Setup Vitess
```bash
cd kube
kubectl apply -f operator.yaml # poczekać aż wstanie
kubectl apply -f 101_initial_cluster.yaml # poczekać aż wstanie
```

#### Seed bazy danych + Port Forwarding
```bash
./pf.sh &
alias mysql="mysql -h 127.0.0.1 -P 15306 -u user"
alias vtctldclient="vtctldclient --server localhost:15999 --alsologtostderr"
vtctldclient ApplySchema --sql="$(cat create_commerce_schema.sql)" commerce
vtctldclient ApplyVSchema --vschema="$(cat vschema_commerce_initial.json)" commerce
```

#### Setup narzędzi do Otel'a
```bash
cd otel
find . -name '*.yaml' -exec kubectl apply -f {} \; # zaaplikowanie kazdego pliku yaml
kubectl port-forward svc/grafana 3000:80 -n telemetry # port forwarding grafany
```

#### Dodanie Prometheusa jako źródło danych
1. Przejdź do zakładki Connections.

2. Wybierz Data Source.

3. Kliknij Add new data source.

4. Z listy dostępnych źródeł wybierz Prometheus.

5. W polu URL wpisz adres: http://prometheus.telemetry.svc.cluster.local:9090

6. Kliknij przycisk Save & test, aby zapisać ustawienia i przetestować połączenie.

#### Przetestowanie dema
```bash
# trzeba byc w ./kube
for i in {1..10000}; do mysql --table < select_commerce_data.sql > /dev/null; done
```

### 8. Otrzymane wyniki
W Grafanie testowaliśmy metrykę o nazwie container_cpu_usage_seconds_total, która służy do mierzenia zużycia CPU przez kontenery. Metryka ta pozwala na dokładną analizę obciążenia CPU generowanego przez poszczególne komponenty systemu uruchomione w kontenerach.

W naszym eksperymencie zebraliśmy dane dla dwóch różnych scenariuszy:

- Bez obciążenia bazy danych – w tym trybie system działał w stanie spoczynku, bez generowania dodatkowego ruchu ani zapytań do bazy danych. Pomiar zużycia CPU w tym scenariuszu pozwala ocenić podstawowe zużycie zasobów przez Vitess oraz powiązane komponenty, co stanowi punkt odniesienia do dalszych analiz.

- Z obciążeniem bazy danych – w tym scenariuszu generowaliśmy ruch i zapytania do bazy danych, aby zasymulować rzeczywiste użytkowanie systemu. Dzięki temu mogliśmy zaobserwować, jak wzrasta zużycie CPU w odpowiedzi na obciążenie oraz ocenić wydajność i skalowalność systemu Vitess pod większym natężeniem pracy.

Poniżej prezentujemy wykresy i dane zebrane z monitoringu, które ilustrują różnice w zużyciu CPU między tymi dwoma stanami, co pozwala na lepsze zrozumienie wpływu obciążenia na zasoby systemowe.

![Alternatiwny](img/metric.png)
![Alternatiwny](img/withoutStress.png)
![Alternatiwny](img/withStress.png)


### 9. Wykorzystanie narzędzi AI

W trakcie tworzenia projektu zasięgaliśmy pomocy narzędzi takich jak ChatGPT czy DeepSeek zarówno w celu znalezienia poprawnych komend tworzących kolejne komponenty systemu jak i dla celów przyśpieszenia pracy przez generowanie mock'ów/prostych komend.

Modele sztucznej inteligencji dodają dodatkowo bardzo dokłądne wytłumaczenie kolejnych kroków, na przykład w tych przypadku:

![Alternatiwny](img/chat4.png)

dlatego zrzuty ekranu obrazujące wykorzystanie modeli są docięte do pytań/odpowiedzi.

Przedstawione narzędzia często miały rację, szczególnie w przypadku najczęściej uzywanych rozwiązań jak kubernetes czy mysql - często konieczne było doprecyzowanie dodatkowych parametrów, lecz komendy zwracane przez program były prawidłowe:

![Alternatiwny](img/chat1.png)
![Alternatiwny](img/chat2.png)
![Alternatiwny](img/chat3.png)

Równiez w przypadku samego Vitessa, chatGPT zdarzał się być przydatny:

![Alternatiwny](img/chat5.png)

, lecz jego przydatność zaczynała się dopiero w momencie kiedy zadało się właściwe pytanie, np. "Jak postawić Vitessa z yamla". Proste pytanie "Jak uruchomić Vitessa" prowadziło do błędnych informacji:

![Alternatiwny](img/chat6.png)

, poniewaz Vitess nie jest juz wspierany przez helma. Oczywiście w momencie zwrócenia na to uwagi, informacja staje się dla niego oczywista:

![Alternatiwny](img/chat7.png)

Tak więc podsumowując wykorzystanie narzędzi AI, są to bardzo wygodne rozwiązania, jednak dopiero wtedy, kiedy jest się obeznanym w temacie i intuicyjnie wie się, kiedy odpowiedzi mają szansę być poprawne, a kiedy nie. Dopóki nie jest się dobrze zaznajomionym z technologią, najlepszym wyborem jest skorzystanie z docsów.

### 10. Wnioski
W przeprowadzonym eksperymencie, którego celem było uruchomienie środowiska Vitess oraz monitorowanie jego działania za pomocą OpenTelemetry, Prometheusa i Grafany, udało się uzyskać szczegółowe informacje na temat zużycia zasobów przez poszczególne komponenty klastra. Analiza metryk pokazała, że największe obciążenie procesora podczas wykonywania zapytań SQL przypada na komponenty vtablet oraz vtgate. vtablet odpowiada za bezpośredni kontakt z bazą danych MySQL, a vtgate pełni funkcję bramy agregującej zapytania i rozdzielającej je do odpowiednich shardów – ich intensywna praca w czasie przetwarzania zapytań jest więc naturalna, ale też stanowi kluczowy punkt obserwacyjny pod kątem optymalizacji.

Z eksperymentu wynikają również inne istotne wnioski – Vitess okazuje się być bardzo zasobożerny, szczególnie jeśli chodzi o zapotrzebowanie na pamięć RAM. Ta obserwacja nie wynika bezpośrednio z wykresów metryk, lecz z praktycznych problemów napotkanych podczas prób uruchomienia klastra Vitess na sprzęcie o ograniczonych zasobach. Próby postawienia środowiska na maszynach z niewielką ilością dostępnej pamięci często kończyły się niepowodzeniem lub niestabilnym działaniem usług. Co więcej, zauważalny jest niedobór przykładów użycia Vitessa w internecie, co utrudnia jego wdrażanie i rozwiązywanie problemów.

Prometheus i Grafana wyróżniają się bardzo dobrą dokumentacją oraz szeroką kompatybilnością z różnymi systemami i usługami. Ich elastyczność oraz bogata kolekcja gotowych dashboardów sprawiają, że integracja z Vitess – choć wymaga pewnej konfiguracji – przebiega sprawnie i pozwala na szybkie uzyskanie wartościowych danych

### 11. Bibliografia
- Vitess: https://vitess.io/docs
- OpenTelemetry: https://opentelemetry.io/docs
- Grafana: https://grafana.com/
- Kubernetess: https://kubernetes.io/
- Mysql: https://www.mysql.com/
- Minikube: https://minikube.sigs.k8s.io/docs/start/
- Docker: https://www.docker.com/
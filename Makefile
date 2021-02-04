KEYCLOAK_SECRET?=00000000-0000-0000-0000-000000000000

create-cluster:
	minikube start --vm=true
	minikube addons enable ingress
	sleep 30

destroy-cluster:
	minikube delete

install-cert-manager:
	@kubectl create namespace cert-manager
	@helm install \
	 cert-manager jetstack/cert-manager \
 	 --namespace cert-manager \
	 --version v1.1.0 \
	 --set installCRDs=true

install-keycloak:
	@helm upgrade --install keycloak bitnami/keycloak -f ./keycloak-values.yaml
	@cat keycloak-ingress.yaml | \
	 sed "s/MINIKUBE_IP/`minikube ip`/" | \
	 kubectl apply -f -

	@echo "Keycloak Admin Username: admin"
	@echo "Keycloak Admin Password: `kubectl get secret --namespace default keycloak-env-vars -o jsonpath="{.data.KEYCLOAK_ADMIN_PASSWORD}" | base64 --decode`"
	@echo "Keycloak URL: https://`kubectl get ingress keycloak-ingress -o jsonpath='{.spec.rules[0].host}'`"

install-grafana:
	@cat grafana-values.yaml | \
	 sed "s/MINIKUBE_IP/`minikube ip`/; s/KEYCLOAK_SECRET/${KEYCLOAK_SECRET}/" | \
	 helm upgrade --install loki grafana/loki-stack \
		--set grafana.enabled=true \
		--set prometheus.enabled=true \
		--set prometheus.alertmanager.persistentVolume.enabled=false \
		--set prometheus.server.persistentVolume.enabled=false \
		-f - 

	@cat grafana-ingress.yaml | \
	 sed "s/MINIKUBE_IP/`minikube ip`/" | \
	 kubectl apply -f -	
	 
	@echo "Grafana Admin username: `kubectl get secret --namespace default loki-grafana -o jsonpath="{.data.admin-user}" | base64 --decode`"	
	@echo "Grafana Admin password: `kubectl get secret --namespace default loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode`"
	@echo "Grafana URL: https://`kubectl get ingress grafana-ingress -o jsonpath='{.spec.rules[0].host}'`"	


uninstall:
	@helm uninstall loki
	@helm uninstall keycloak	

start-example:
	@cd myapp && $(MAKE) start

stop-example:
	@cd myapp && $(MAKE) stop

install-elastic-stack:
	@kubectl apply -f ./elastic-elasticsearch.yaml
	@kubectl apply -f ./elastic-kibana.yaml
	@cat kibana-ingress.yaml | \
	 sed "s/MINIKUBE_IP/`minikube ip`/" | \
	 kubectl apply -f -

copy-kibana-password-to-clipboard:
	@kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode | pbcopy
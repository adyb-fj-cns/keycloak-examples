curl -s \
-d "client_id=grafana" \
-d "client_secret=f730bb98-ea98-4a8d-8973-bc52a8a6ae03" \
-d "username=adybuxton" \
-d "password=password" \
-d "grant_type=password" \
"http://keycloak.192.168.64.34.nip.io/auth/realms/grafana/protocol/openid-connect/token" | jq -r '.access_token'
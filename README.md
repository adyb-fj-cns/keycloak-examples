# Keyclock Examples

## Setting up (non-ssl approach)

1. Setup the cluster and install keycloak

```
make create-cluster install-keycloak
```

## Setting up Grafana Integration (non-ssl approach) for a non admin user

1. Login to Keycloak using the k8s ingress url. Ignore SSL errors!
2. Add `grafana` realm. Keycloak appears to be case sensitive so watch out!
3. Add user to the grafana realm (needs email, first name and surname populating as this is pulled through)
4. Add credentials to the User and uncheck the temporary option
5. Add new client to the realm (call it grafana), use openid-connect protocol
6. On the client cettings tab modify access type to confidential and (for now put `*` as the Valid Eedirect URI)
7. On the client credentials tab take the secret (guid) and note it locally
8. Install Grafana and pass the secret to the helm chart values file

```
make install-grafana KEYCLOAK_SECRET=<insert guid here>
```

9. Take the Grafana ingress URL (outputted from the last command) and update the the Root URL of the Grafana Realms Grafana Client (created above) with the URL
10. Login to Grafana with the new keycloak user credentials.

## Modifying user to have admin rights

1. Logout Grafana if logged in and logout of sessions in Keycloak.
2. Create a Mapper in the `grafana` client
   - Name: `Roles`
   - Mapper Type: `User Client Role`
   - Client ID: `grafana`
   - Claim JSON Type: `string`
3. Create new `admin` client role in the grafana client (Dont worry about realm role for now!).
4. Assign the client role to the user created
   1. Click on Users
   2. View all users
   3. Click User guid
   4. Click Role Mappings
   5. Click client roles and select grafana
   6. Click the `admin` available role to assigned
5. (Optional) Verify the role will be propogated
   1. Modify `test.sh` to include correct details
   2. Run `sh ./test.sh`
      1. Copy output into https://jwt.io/#debugger-io
      2. Copy decoded payload data into https://jmespath.org/ together with the JMESPath defined in the `grafana-values.yaml` file attribute `role_attribute_path`. Example is `contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'`
   3. If configured the Result should be "Admin"
6. Login again and you should be admin

## Random Links

- https://janikvonrotz.ch/2020/08/27/grafana-oauth-with-keycloak-and-how-to-validate-a-jwt-token/
- https://docs.bitnami.com/tutorials/integrate-keycloak-authentication-kubernetes/
- https://www.keycloak.org/getting-started/getting-started-kube
- https://bitnami.com/stack/keycloak/helm
- https://expressjs.com/
- https://github.com/tilt-dev/tilt-example-nodejs
- https://grafana.com/docs/grafana/latest/auth/generic-oauth/
- https://www.keycloak.org/docs/latest/getting_started/
- https://dev.to/techworld_with_nana/how-to-setup-a-keycloak-gatekeeper-to-secure-the-services-in-your-kubernetes-cluster-5d2d
- https://django-keycloak.readthedocs.io/en/latest/
- https://www.keycloak.org/docs/latest/server_installation/#_operator
- https://www.elastic.co/guide/en/cloud-on-k8s/1.0/k8s-pod-template.html
- https://www.elastic.co/guide/en/elasticsearch/reference/current/oidc-guide-authentication.html
- https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html
- https://discuss.elastic.co/t/elk-stack-integration-with-keycloak/210909/7 (Perhaps needs platinum (trial licence))

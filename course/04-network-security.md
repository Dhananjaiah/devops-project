# Module 04: Network Security

## Goals

- Expose apps with Routes (HTTP/HTTPS) and Ingress resources
- Configure TLS termination: edge, re-encrypt, passthrough
- Implement NetworkPolicies for pod-to-pod security
- Use default-deny policies and selective allow rules
- Secure Routes with custom certificates
- Troubleshoot 503 errors and certificate issues

## Key Terms

- **Route**: OpenShift resource exposing Service via Router (HAProxy-based)
- **Ingress**: Kubernetes-native resource for HTTP routing
- **Edge Termination**: TLS terminates at Router; backend uses HTTP
- **Re-encrypt**: TLS terminates at Router, re-encrypted to backend
- **Passthrough**: TLS passes through Router to backend (end-to-end encryption)
- **NetworkPolicy**: Firewall rules for pod ingress/egress traffic
- **Default-deny**: Policy blocking all traffic; explicit allows required

## Commands First

```bash
# Create HTTP Route (insecure)
oc expose service myapp --name=myapp-route
oc get route myapp-route

# Create HTTPS Route with edge termination (Router handles TLS)
oc create route edge myapp-edge \
  --service=myapp \
  --hostname=myapp.${APPS_DOMAIN} \
  --insecure-policy=Redirect  # HTTP -> HTTPS redirect

# Re-encrypt Route (TLS to Router, re-encrypted to Pod)
oc create route reencrypt myapp-reencrypt \
  --service=myapp \
  --hostname=myapp-secure.${APPS_DOMAIN} \
  --dest-ca-cert=/path/to/backend-ca.crt

# Passthrough Route (TLS directly to Pod)
oc create route passthrough myapp-passthrough \
  --service=myapp \
  --hostname=myapp-tls.${APPS_DOMAIN}

# Custom certificate for Route
oc create route edge myapp-custom-cert \
  --service=myapp \
  --cert=/path/to/tls.crt \
  --key=/path/to/tls.key \
  --ca-cert=/path/to/ca.crt

# Test Route
curl -I http://myapp-route-${NS}.${APPS_DOMAIN}
curl -k https://myapp-edge-${NS}.${APPS_DOMAIN}

# Create default-deny NetworkPolicy
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: ${NS}
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Allow ingress from specific namespace (e.g., ingress controller)
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-openshift-ingress
  namespace: ${NS}
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          network.openshift.io/policy-group: ingress
EOF

# Allow specific pod-to-pod traffic
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: ${NS}
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
EOF

# Allow DNS egress (critical for most apps)
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: ${NS}
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: openshift-dns
    ports:
    - protocol: UDP
      port: 53
EOF

# List NetworkPolicies
oc get networkpolicies -n ${NS}
oc describe networkpolicy default-deny-all -n ${NS}

# Delete NetworkPolicy
oc delete networkpolicy default-deny-all -n ${NS}
```

**Why/Notes**: Routes are OpenShift's preferred way to expose apps (more features than Ingress). Edge termination is common; passthrough for end-to-end encryption. NetworkPolicies are critical for multi-tenant security. Always allow DNS egress.

## Verify

```bash
# Check Routes
oc get routes -n ${NS}
oc describe route myapp-edge -n ${NS}

# Test Route accessibility
curl -I http://myapp-route-${NS}.${APPS_DOMAIN}
curl -k -I https://myapp-edge-${NS}.${APPS_DOMAIN}

# Verify NetworkPolicies applied
oc get networkpolicy -n ${NS}
oc describe networkpolicy allow-frontend-to-backend -n ${NS}

# Test pod connectivity before and after NetworkPolicy
oc run test-pod --image=nicolaka/netshoot -n ${NS} -- sleep 3600
oc exec test-pod -n ${NS} -- curl -m 5 http://backend-service:8080  # Should succeed/fail based on policy
```

Expected: Routes return 200 OK or redirect to HTTPS. NetworkPolicies block/allow traffic as configured.

## Mini-Lab (5-10 min)

**Scenario**: Deploy frontend and backend pods. Secure with NetworkPolicies allowing only frontend→backend traffic.

1. **Deploy backend service**:

```bash
oc new-project demo-netpol
oc create deployment backend --image=nginx:1.25
oc set env deployment/backend MESSAGE="Backend API"
oc label deployment backend app=backend
oc expose deployment backend --port=80
```

2. **Deploy frontend service**:

```bash
oc create deployment frontend --image=nginx:1.25
oc set env deployment/frontend MESSAGE="Frontend UI"
oc label deployment frontend app=frontend
oc expose deployment frontend --port=80
oc expose service frontend  # Create Route
```

3. **Test connectivity (before NetworkPolicy)**:

```bash
BACKEND_POD=$(oc get pod -l app=backend -o jsonpath='{.items[0].metadata.name}')
FRONTEND_POD=$(oc get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}')

oc exec $FRONTEND_POD -- curl -s -m 5 http://backend  # Should succeed
oc run test --image=busybox --rm -it --restart=Never -- wget -qO- --timeout=5 http://backend  # Should succeed
```

4. **Apply default-deny and selective allow**:

```bash
# Block all ingress
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

# Allow frontend -> backend
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
EOF

# Allow ingress to frontend (from OpenShift Router)
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-to-frontend
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          network.openshift.io/policy-group: ingress
    ports:
    - protocol: TCP
      port: 80
EOF
```

5. **Verify policies**:

```bash
# Frontend can reach backend (allowed)
oc exec $FRONTEND_POD -- curl -s -m 5 http://backend  # Should succeed

# Random pod cannot reach backend (denied)
oc run test --image=busybox --rm -it --restart=Never -- wget -qO- --timeout=5 http://backend  # Should timeout/fail

# External access to frontend via Route (allowed)
ROUTE_URL=$(oc get route frontend -o jsonpath='{.spec.host}')
curl -s http://$ROUTE_URL  # Should succeed
```

6. **Create edge-terminated TLS Route**:

```bash
oc create route edge frontend-tls --service=frontend
oc get route frontend-tls -o yaml | grep -A2 tls

ROUTE_URL=$(oc get route frontend-tls -o jsonpath='{.spec.host}')
curl -k -I https://$ROUTE_URL  # Should return 200 OK
```

## Quiz (5 Questions)

1. **Q**: What's the difference between edge and passthrough TLS termination?  
   **A**: Edge terminates TLS at Router (HTTP to backend); passthrough sends TLS directly to pod.

2. **Q**: How do you force HTTP traffic to redirect to HTTPS?  
   **A**: Add `--insecure-policy=Redirect` when creating Route.

3. **Q**: What does a default-deny NetworkPolicy do?  
   **A**: Blocks all ingress/egress traffic; pods can't communicate without explicit allow rules.

4. **Q**: How do you allow ingress from OpenShift Router to your pods?  
   **A**: Create NetworkPolicy with `namespaceSelector` matching `network.openshift.io/policy-group: ingress`.

5. **Q**: Why do apps often fail after applying NetworkPolicies?  
   **A**: DNS egress is blocked; must explicitly allow traffic to `openshift-dns` namespace on port 53/UDP.

## Common Mistakes

- **Forgetting DNS egress**: Apps can't resolve hostnames without allowing port 53/UDP to openshift-dns.
- **Not allowing Router ingress**: Routes return 503 if NetworkPolicy blocks ingress-controller namespace.
- **Using HTTP Route for sensitive data**: Always use edge/re-encrypt/passthrough for production.
- **Testing TLS with curl without `-k`**: Self-signed certs fail; use `-k` for testing or add CA to trust store.
- **Overlapping NetworkPolicies**: Multiple policies are OR'd (union); unexpected allows can occur.

## Troubleshooting

See [Triage Matrix: Route & NetworkPolicy Issues](../troubleshooting/triage-matrix.md#network-security)

**Symptom**: Route returns 503 Service Unavailable  
**Triage**: `oc get route <name>` shows route exists; `oc get endpoints <service>` shows no endpoints  
**Fix**: Check pod selector matches service selector; verify pods are ready  
**Prevent**: Use `oc status` to verify service→pod linkage before creating Route

**Symptom**: Pod can't reach external services after NetworkPolicy applied  
**Triage**: `oc exec <pod> -- curl -m 5 http://example.com` times out  
**Fix**: Add egress NetworkPolicy allowing external traffic or DNS  
**Prevent**: Start with ingress-only policies; add egress policies incrementally

---

**Next**: [Module 05: Non-HTTP & SNI Applications](05-non-http-and-sni-apps.md)

# Module 10: Comprehensive Review

## Goals

- Tie together all 9 modules with integrated scenarios
- Complete time-boxed drills covering multiple topics
- Practice exam-style tasks under time constraints
- Review common pitfalls and quick fixes
- Build confidence for real-world operations and certification exams

## Review Checklist

```bash
# Module 01: Declarative Resources
- [ ] Create project with labels
- [ ] Apply manifests with dry-run
- [ ] Use Kustomize for dev/prod overlays
- [ ] Diff changes before applying

# Module 02: Packaged Apps
- [ ] Deploy from Template
- [ ] Install Helm chart with custom values
- [ ] Upgrade and rollback Helm release
- [ ] Export template to YAML

# Module 03: Auth & RBAC
- [ ] Configure HTPasswd IdP
- [ ] Create users and groups
- [ ] Grant project admin vs view access
- [ ] Test permissions with can-i

# Module 04: Network Security
- [ ] Create edge-terminated Route
- [ ] Apply default-deny NetworkPolicy
- [ ] Allow frontend→backend traffic
- [ ] Allow ingress from Router

# Module 05: Non-HTTP Apps
- [ ] Expose service as NodePort
- [ ] Create passthrough Route for TLS
- [ ] Configure headless service
- [ ] Test service connectivity

# Module 06: Self-Service
- [ ] Create ResourceQuota and LimitRange
- [ ] Disable/enable self-provisioner
- [ ] Apply project request template
- [ ] Test quota enforcement

# Module 07: Operators
- [ ] Install Operator from OperatorHub
- [ ] Create Custom Resource
- [ ] Upgrade Operator channel
- [ ] Uninstall Operator safely

# Module 08: Security & SCC
- [ ] Assign anyuid SCC to ServiceAccount
- [ ] Create Secret and restrict access
- [ ] Apply SecurityContext hardening
- [ ] Enable PSA warnings

# Module 09: Maintenance
- [ ] Cordon and drain node
- [ ] Backup namespace resources
- [ ] Configure internal registry
- [ ] Check cluster health

# Module 10: Integration
- [ ] Complete multi-module scenarios
- [ ] Troubleshoot realistic issues
- [ ] Perform under time pressure
```

## Scenario 1: Secure Multi-Tier App (20 min)

**Task**: Deploy frontend, backend, database with NetworkPolicies, Secrets, Routes, and Quotas.

```bash
# 1. Setup (2 min)
oc new-project review-app
oc create quota review-quota --hard=pods=15,requests.cpu=2,requests.memory=4Gi
oc create limitrange review-limits \
  --type=Container \
  --default-request=cpu=100m,memory=128Mi \
  --default=cpu=200m,memory=256Mi

# 2. Deploy database (3 min)
oc create secret generic db-creds \
  --from-literal=user=appuser \
  --from-literal=password=secure123
oc create deployment postgres --image=postgres:15-alpine
oc set env deployment/postgres --from=secret/db-creds --prefix=POSTGRES_
oc label deployment postgres app=postgres tier=database
oc expose deployment postgres --port=5432

# 3. Deploy backend (3 min)
oc create deployment backend --image=nginx:1.25
oc set env deployment/backend DB_HOST=postgres DB_USER=appuser
oc label deployment backend app=backend tier=api
oc expose deployment backend --port=80

# 4. Deploy frontend (3 min)
oc create deployment frontend --image=nginx:1.25
oc set env deployment/frontend API_URL=http://backend
oc label deployment frontend app=frontend tier=web
oc expose deployment frontend --port=80
oc create route edge frontend --service=frontend --insecure-policy=Redirect

# 5. Apply NetworkPolicies (4 min)
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-ingress
spec:
  podSelector:
    matchLabels:
      tier: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          network.openshift.io/policy-group: ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      tier: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: web
    ports:
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-db
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: api
    ports:
    - protocol: TCP
      port: 5432
EOF

# 6. Verify (5 min)
oc get all,route,networkpolicy
oc describe quota review-quota
ROUTE_URL=$(oc get route frontend -o jsonpath='{.spec.host}')
curl -I https://${ROUTE_URL}

# Test connectivity
FRONTEND_POD=$(oc get pod -l tier=web -o jsonpath='{.items[0].metadata.name}')
BACKEND_POD=$(oc get pod -l tier=api -o jsonpath='{.items[0].metadata.name}')
oc exec ${FRONTEND_POD} -- curl -s -m 5 http://backend  # Should succeed
oc exec ${BACKEND_POD} -- nc -zv postgres 5432  # Should succeed
oc run test --image=busybox --rm -it --restart=Never -- wget -qO- --timeout=5 http://backend  # Should fail (blocked by NP)
```

**Success Criteria**: Frontend accessible via HTTPS Route, backend/DB only accessible internally via NetworkPolicies, quotas enforced.

## Scenario 2: Operator & SCC Integration (15 min)

**Task**: Install Operator, create CR, grant SCC for privileged workload.

```bash
# 1. Setup (2 min)
oc new-project review-operator

cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: review-og
  namespace: review-operator
spec:
  targetNamespaces:
  - review-operator
EOF

# 2. Install Operator (3 min)
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cert-manager
  namespace: review-operator
spec:
  channel: stable
  name: cert-manager
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF

oc get csv -n review-operator -w  # Wait for Succeeded

# 3. Create Custom Resource (2 min)
cat <<EOF | oc apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: review-issuer
  namespace: review-operator
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: review-cert
  namespace: review-operator
spec:
  secretName: review-tls
  issuerRef:
    name: review-issuer
  dnsNames:
  - review.example.com
EOF

oc get certificate -n review-operator

# 4. Deploy privileged app (3 min)
oc create serviceaccount privileged-sa -n review-operator
oc adm policy add-scc-to-user anyuid -z privileged-sa -n review-operator

cat <<EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: privileged-app
  namespace: review-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: privileged
  template:
    metadata:
      labels:
        app: privileged
    spec:
      serviceAccountName: privileged-sa
      containers:
      - name: app
        image: nginx
        securityContext:
          runAsUser: 0
EOF

# 5. Verify (5 min)
oc get pods -n review-operator
oc get pod -l app=privileged -o yaml | grep 'openshift.io/scc'  # Should show anyuid
oc get secret review-tls -n review-operator -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -text | grep Subject
```

**Success Criteria**: Operator installed, CR creates TLS secret, privileged app runs with anyuid SCC.

## Scenario 3: Node Maintenance & Backup (15 min)

**Task**: Drain node, backup resources, restore after simulated failure.

```bash
# 1. Create test resources (3 min)
oc new-project review-backup
oc create deployment app --image=nginx --replicas=3
oc expose deployment app --port=80
oc create route edge app --service=app
oc create secret generic creds --from-literal=token=abc123
oc create configmap config --from-literal=env=production

# 2. Backup (2 min)
mkdir -p ~/review-backups
oc get all,route,secret,cm -n review-backup -o yaml > ~/review-backups/review-backup.yaml

# 3. Drain node (3 min)
NODE=$(oc get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[0].metadata.name}')
oc adm cordon ${NODE}
oc adm drain ${NODE} --ignore-daemonsets --delete-emptydir-data --grace-period=30
oc get pods -n review-backup -o wide  # Pods moved to other nodes

# 4. Simulate disaster (2 min)
oc delete project review-backup
sleep 30

# 5. Restore (3 min)
oc new-project review-backup
oc apply -f ~/review-backups/review-backup.yaml
oc get all,route,secret,cm -n review-backup

# 6. Uncordon node (2 min)
oc adm uncordon ${NODE}
oc get nodes
```

**Success Criteria**: Node drained without pod disruption, resources restored from backup, node returned to service.

## Time-Boxed Drills

### Drill 1: Rapid Troubleshooting (10 min)

Fix 3 broken deployments:

```bash
oc new-project drill-troubleshoot

# Broken 1: Image pull error
oc create deployment broken1 --image=nonexistent/image:latest
# Fix: oc set image deployment/broken1 *=nginx:latest

# Broken 2: Quota exceeded
oc create quota tight --hard=pods=1
oc create deployment broken2 --image=nginx --replicas=3
# Fix: oc scale deployment/broken2 --replicas=1 OR oc delete quota tight

# Broken 3: SCC violation
cat <<EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: broken3
  template:
    metadata:
      labels:
        app: broken3
    spec:
      containers:
      - name: app
        image: nginx
        securityContext:
          runAsUser: 0
EOF
# Fix: Create SA with anyuid, set serviceAccountName
```

### Drill 2: Security Hardening (10 min)

Secure an existing deployment:

```bash
oc new-project drill-security
oc create deployment insecure --image=nginx

# Tasks:
# 1. Add SecurityContext (non-root, drop capabilities)
# 2. Mount secret as volume (not env var)
# 3. Apply NetworkPolicy (ingress from specific label)
# 4. Create edge Route with HTTPS redirect
```

### Drill 3: Resource Management (10 min)

Implement quotas and limits:

```bash
oc new-project drill-resources

# Tasks:
# 1. Create quota: 5 pods, 1 CPU, 2Gi memory
# 2. Create LimitRange with defaults
# 3. Deploy 3-replica app within quota
# 4. Try to exceed quota (fail gracefully)
```

## Common Pitfalls Review

1. **Forgetting namespace flag**: `oc get pods` defaults to current project
2. **Not using dry-run**: `oc apply --dry-run=server` catches errors early
3. **Ignoring NetworkPolicy DNS**: Must allow egress to openshift-dns
4. **Granting cluster-admin liberally**: Use project-scoped admin instead
5. **Not testing RBAC**: Always verify with `oc auth can-i`
6. **Skipping backup before changes**: DANGER: Always backup critical resources
7. **Using imperative commands for prod**: Declarative YAML is auditable/repeatable
8. **Not checking cluster health**: `oc get co` before/after maintenance
9. **Removing Operator before CRs**: Delete CRs first to avoid orphans
10. **Forgetting grace period on drain**: Abrupt termination can corrupt data

## Quick Fixes Reference

```bash
# Pod stuck in Pending (quota)
oc describe quota -n ${NS}
oc delete deployment <unused> -n ${NS}

# Pod stuck in ImagePullBackOff
oc describe pod <pod> | grep -A5 Events
oc set image deployment/<name> *=<correct-image>

# Route 503 error
oc get endpoints <service>  # Empty? Check pod selector
oc get pods -l <selector>  # Pods ready?

# NetworkPolicy blocking traffic
oc delete networkpolicy <name>  # Temporary to test
oc describe networkpolicy <name>  # Review rules

# SCC violation
oc get pod <pod> -o yaml | grep scc
oc create sa <name> && oc adm policy add-scc-to-user <scc> -z <sa>

# Secret not accessible
oc auth can-i get secret <name> --as=system:serviceaccount:<ns>:<sa>
oc create rolebinding <name> --role=<role> --serviceaccount=<ns>:<sa>
```

## Final Checklist

Before attempting mock exams or production work:

- [ ] Completed all 10 module labs
- [ ] Reviewed troubleshooting matrix
- [ ] Practiced 3 time-boxed drills
- [ ] Can navigate cheatsheets quickly
- [ ] Comfortable with `oc`, `oc adm`, `helm` CLIs
- [ ] Understand RBAC, NetworkPolicies, SCCs
- [ ] Can install/upgrade Operators
- [ ] Know how to backup/restore resources
- [ ] Practiced under time pressure

## Next Steps

1. Complete [Capstone Project](../project/README.md) - Deploy FoodCart app with full stack
2. Take [Mock Exam 1](../exams/mock-exam-1.md) - 60 min, 15 tasks
3. Review [Troubleshooting Matrix](../troubleshooting/triage-matrix.md) - Systematic triage
4. Practice [Mock Exam 2](../exams/mock-exam-2.md) - 60 min, harder scenarios
5. Build your own multi-tier app with all security controls

## Conclusion

You've mastered OpenShift administration fundamentals. Focus on:

- **Speed**: Use cheatsheets and command history (`Ctrl+R`)
- **Safety**: Always dry-run and backup before changes
- **Troubleshooting**: Systematic approach (symptom → triage → fix → prevent)
- **Security**: Least privilege, NetworkPolicies, SCCs
- **Automation**: Declarative YAML, Kustomize, GitOps

**Good luck on your certification and real-world operations!**

---

**Next**: [Capstone Project: FoodCart on OpenShift](../project/README.md)

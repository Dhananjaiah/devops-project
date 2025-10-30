# Mock Exam 2: OpenShift Advanced Administration

**Time Limit**: 60 minutes  
**Passing Score**: 12/15 tasks (80%)  
**Environment**: OpenShift 4.14 cluster with cluster-admin access  
**Difficulty**: Harder than Mock Exam 1

## Instructions

- This exam tests advanced scenarios and troubleshooting
- Complete as many tasks as possible within 60 minutes
- Some tasks are intentionally vague (like real-world scenarios)
- Use your knowledge to make reasonable assumptions
- Document all commands for verification

---

## Task 1: Multi-Tier Application Deployment (2 points)

Deploy a 3-tier application in namespace `shop-prod`:

**Frontend** (`shop-web`):
- nginx:1.25, 3 replicas
- Exposed via HTTPS edge Route
- Labels: app=shop, tier=frontend

**API** (`shop-api`):
- httpd:2.4, 2 replicas  
- Not exposed externally
- Labels: app=shop, tier=api

**Database** (`shop-db`):
- postgres:15, 1 replica (StatefulSet)
- 5Gi PVC
- Labels: app=shop, tier=database

**Network Requirements**:
- Default deny all ingress
- Frontend accessible from internet
- Frontend can reach API only
- API can reach database only
- All pods can resolve DNS

**Verification**: Route works, internal connectivity correct, external access blocked

---

## Task 2: Advanced RBAC Configuration (1 point)

Create a custom ClusterRole `pod-manager` that can:
- Get, list, watch, create, delete pods
- Get, list pod logs
- But CANNOT delete namespaces or nodes

Grant this role to user `operator1` in namespace `shop-prod` only.

Create a ClusterRole `node-viewer` that can only view nodes (get, list, watch).
Grant it cluster-wide to group `platform-team`.

**Verification**: Test with `oc auth can-i` as different users

---

## Task 3: Resource Management & Limits (1 point)

In `shop-prod`:
1. Create LimitRange enforcing:
   - Default: 200m CPU, 256Mi memory
   - Max per container: 1 CPU, 1Gi memory
   - Min per container: 50m CPU, 64Mi memory

2. Update ResourceQuota to:
   - 15 pods max
   - 4 CPU requests, 8 CPU limits
   - 8Gi memory requests, 16Gi memory limits
   - 5 PVCs max
   - 3 LoadBalancer services max

**Verification**: Deploy pod without requests/limits; check it gets defaults

---

## Task 4: Operator Lifecycle Management (1 point)

1. Install PostgreSQL Operator (Crunchy Data) from certified-operators
2. Change subscription to manual approval
3. Create a PostgresCluster CR with:
   - Name: shop-db-ha
   - Version: 15
   - 2 replicas
   - 10Gi storage per instance
   - Backups enabled with 5Gi repo

**Verification**: PostgreSQL cluster with 2 pods running

---

## Task 5: Security Hardening (1 point)

For the `shop-web` deployment:
1. Run as non-root (uid 1001)
2. Read-only root filesystem
3. Drop ALL capabilities
4. Set security context: allowPrivilegeEscalation=false
5. Add seccomp profile: RuntimeDefault

**Verification**: Pod passes restricted PSS policy

---

## Task 6: Troubleshooting: CrashLoopBackOff (1 point)

A deployment `failing-app` exists in `troubleshoot-ns` namespace. It's in CrashLoopBackOff.

1. Identify the root cause
2. Fix the issue
3. Document what was wrong

**Hint**: Check logs, describe pod, look at resource limits

**Verification**: Pod runs successfully

---

## Task 7: Troubleshooting: NetworkPolicy (1 point)

In `network-test` namespace, `client-pod` cannot reach `server-pod` on port 8080.

Diagnose and fix the NetworkPolicy issue without deleting existing policies.

**Verification**: `oc exec client-pod -- curl -s server-pod:8080` succeeds

---

## Task 8: Troubleshooting: Pending Pod (1 point)

A pod `stuck-pod` in `quota-ns` namespace is Pending.

1. Identify why it's pending
2. Fix the issue with minimal impact
3. Explain the root cause

**Verification**: Pod moves to Running state

---

## Task 9: Cluster Maintenance Simulation (1 point)

Perform rolling maintenance on worker nodes:
1. Select 2 worker nodes
2. Safely drain first node
3. Simulate maintenance (wait 30 seconds)
4. Restore node to service
5. Repeat for second node
6. Verify all pods rescheduled

**Verification**: All nodes Ready, no pods stuck

---

## Task 10: ImageStream & BuildConfig (1 point)

1. Create ImageStream `custom-app` in `build-ns`
2. Import image from `docker.io/library/httpd:2.4` as `custom-app:v1`
3. Create a simple BuildConfig (Source-to-Image not required, just image reference)
4. Trigger build and verify new image

**Verification**: ImageStream shows multiple tags

---

## Task 11: ConfigMap Rollout (1 point)

1. Create ConfigMap `app-settings` with key `feature_flag=false`
2. Mount it in `rolling-app` deployment as /config/settings
3. Update ConfigMap to `feature_flag=true`
4. Force deployment rollout to pick up new config

**Verification**: Pod has updated config without downtime

---

## Task 12: StatefulSet & Headless Service (1 point)

Create a StatefulSet `redis-cluster` in `cache-ns`:
- 3 replicas
- redis:7-alpine image
- Headless service named `redis-cluster`
- 1Gi PVC per pod

**Verification**: DNS returns 3 pod IPs for `redis-cluster` service

---

## Task 13: Secret Management (1 point)

1. Create external secret for database in `shop-prod`
   - host: `external-db.example.com`
   - port: `5432`
   - username: `shopuser`
   - password: `secure456`

2. Create Role `secret-manager` that can create/update/delete secrets
3. Bind role to ServiceAccount `app-deployer` in `shop-prod`

**Verification**: SA can manage secrets, cannot delete pods

---

## Task 14: HPA & Load Testing (1 point)

1. Configure HPA for `shop-web` deployment:
   - Min: 3, Max: 10
   - CPU target: 60%
   - Memory target: 80%

2. Generate load to trigger scaling
3. Monitor HPA until it scales to at least 5 replicas

**Verification**: HPA shows 5+ replicas, load distributed

---

## Task 15: Disaster Recovery Scenario (2 points)

The `shop-prod` namespace was accidentally deleted by a developer.

1. Recreate namespace
2. Restore all resources from backup at `/tmp/shop-backup.yaml` (you must create this backup first from another test namespace)
3. Verify all services operational
4. Implement prevention: create RoleBinding to prevent developers from deleting namespaces

**Verification**: Application restored, RBAC prevents future deletions

---

## Solutions

### Task 1 Solution

```bash
oc new-project shop-prod

# Frontend
oc create deployment shop-web --image=nginx:1.25 --replicas=3 -n shop-prod
oc label deployment shop-web app=shop tier=frontend -n shop-prod
oc expose deployment shop-web --port=80 -n shop-prod
oc create route edge shop-web --service=shop-web -n shop-prod

# API
oc create deployment shop-api --image=httpd:2.4 --replicas=2 -n shop-prod
oc label deployment shop-api app=shop tier=api -n shop-prod
oc expose deployment shop-api --port=80 -n shop-prod

# Database
cat <<EOF | oc apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: shop-db
  namespace: shop-prod
  labels:
    app: shop
    tier: database
spec:
  serviceName: shop-db
  replicas: 1
  selector:
    matchLabels:
      app: shop
      tier: database
  template:
    metadata:
      labels:
        app: shop
        tier: database
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_PASSWORD
          value: pgpass123
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 5Gi
---
apiVersion: v1
kind: Service
metadata:
  name: shop-db
  namespace: shop-prod
spec:
  clusterIP: None
  selector:
    app: shop
    tier: database
  ports:
  - port: 5432
EOF

# NetworkPolicies
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: shop-prod
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-ingress
  namespace: shop-prod
spec:
  podSelector:
    matchLabels:
      tier: frontend
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
  name: allow-frontend-to-api
  namespace: shop-prod
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
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
  namespace: shop-prod
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
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: shop-prod
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

# Verify
ROUTE=$(oc get route shop-web -n shop-prod -o jsonpath='{.spec.host}')
curl -kI https://${ROUTE}
```

### Task 2 Solution

```bash
cat <<EOF | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-manager
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch", "create", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-viewer
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
EOF

oc create rolebinding operator1-pods \
  --clusterrole=pod-manager \
  --user=operator1 \
  -n shop-prod

oc create clusterrolebinding platform-nodes \
  --clusterrole=node-viewer \
  --group=platform-team

# Verify
oc auth can-i delete pods --as=operator1 -n shop-prod  # yes
oc auth can-i delete namespaces --as=operator1  # no
```

### Task 3 Solution

```bash
cat <<EOF | oc apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: shop-limits
  namespace: shop-prod
spec:
  limits:
  - type: Container
    default:
      cpu: "200m"
      memory: "256Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "1"
      memory: "1Gi"
    min:
      cpu: "50m"
      memory: "64Mi"
EOF

oc patch resourcequota -n shop-prod --type=merge -p '
{
  "spec": {
    "hard": {
      "pods": "15",
      "requests.cpu": "4",
      "requests.memory": "8Gi",
      "limits.cpu": "8",
      "limits.memory": "16Gi",
      "persistentvolumeclaims": "5",
      "services.loadbalancers": "3"
    }
  }
}'

# Test
oc run test --image=nginx -n shop-prod
oc get pod test -n shop-prod -o yaml | grep -A10 resources
```

### Task 4 Solution

```bash
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: postgres-og
  namespace: shop-prod
spec:
  targetNamespaces:
  - shop-prod
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: postgresql
  namespace: shop-prod
spec:
  channel: v5
  name: postgresql
  source: certified-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Manual
EOF

# Approve InstallPlan when ready
INSTALL_PLAN=$(oc get ip -n shop-prod -o jsonpath='{.items[?(@.spec.approved==false)].metadata.name}')
oc patch installplan ${INSTALL_PLAN} -n shop-prod --type=merge -p '{"spec":{"approved":true}}'

# Create CR (wait for CSV Succeeded first)
cat <<EOF | oc apply -f -
apiVersion: postgres-operator.crunchydata.com/v1beta1
kind: PostgresCluster
metadata:
  name: shop-db-ha
  namespace: shop-prod
spec:
  postgresVersion: 15
  instances:
  - replicas: 2
    dataVolumeClaimSpec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi
  backups:
    pgbackrest:
      repos:
      - name: repo1
        volume:
          volumeClaimSpec:
            accessModes:
            - ReadWriteOnce
            resources:
              requests:
                storage: 5Gi
EOF
```

### Task 5 Solution

```bash
oc patch deployment shop-web -n shop-prod --type=merge -p '
{
  "spec": {
    "template": {
      "spec": {
        "securityContext": {
          "runAsUser": 1001,
          "runAsNonRoot": true,
          "seccompProfile": {
            "type": "RuntimeDefault"
          }
        },
        "containers": [{
          "name": "nginx",
          "securityContext": {
            "allowPrivilegeEscalation": false,
            "capabilities": {
              "drop": ["ALL"]
            },
            "readOnlyRootFilesystem": true
          },
          "volumeMounts": [{
            "name": "tmp",
            "mountPath": "/tmp"
          }, {
            "name": "cache",
            "mountPath": "/var/cache/nginx"
          }]
        }],
        "volumes": [{
          "name": "tmp",
          "emptyDir": {}
        }, {
          "name": "cache",
          "emptyDir": {}
        }]
      }
    }
  }
}'

oc get pods -n shop-prod
```

### Tasks 6-15 Solutions

*Due to length constraints, detailed solutions for Tasks 6-15 follow the same pattern: identify issue, apply fix, verify. Key troubleshooting steps include:*

**Task 6**: Check logs with `oc logs --previous`, fix OOMKilled or crash errors  
**Task 7**: Add allow rule in NetworkPolicy for client→server  
**Task 8**: Increase quota or delete unused resources  
**Task 9**: Use `oc adm cordon/drain/uncordon` workflow  
**Task 10**: Use `oc import-image` and `oc new-build`  
**Task 11**: Update ConfigMap, `oc rollout restart deployment`  
**Task 12**: Create StatefulSet with volumeClaimTemplates and headless service  
**Task 13**: Create secret, Role with secrets permissions, RoleBinding  
**Task 14**: Create HPA, use load generator script  
**Task 15**: Backup with `oc get all -o yaml`, restore with `oc apply -f`, add RBAC prevention

---

## Scoring

- **15/15**: Expert level! Certification ready
- **12-14**: Strong! Minor review needed
- **9-11**: Good foundation. Practice advanced scenarios
- **< 9**: Review modules 7-10 and troubleshooting

## Key Skills Tested

✅ Multi-tier application architecture  
✅ Advanced RBAC (custom roles, groups)  
✅ Resource management at scale  
✅ Operator lifecycle (manual approval, CRs)  
✅ Security hardening (PSS, SecurityContext)  
✅ Systematic troubleshooting (CrashLoop, NetworkPolicy, Quota)  
✅ Node maintenance workflows  
✅ Image management (ImageStreams, builds)  
✅ ConfigMap updates without downtime  
✅ StatefulSets & persistent storage  
✅ Disaster recovery procedures

This exam reflects real SRE/platform engineering scenarios. Good luck!

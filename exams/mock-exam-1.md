# Mock Exam 1: OpenShift Administration & Operations

**Time Limit**: 60 minutes  
**Passing Score**: 12/15 tasks (80%)  
**Environment**: OpenShift 4.14 cluster with cluster-admin access

## Instructions

- Complete as many tasks as possible within 60 minutes
- Each task is worth 1 point
- Partial credit may be given for partially correct solutions
- Use only CLI tools (`oc`, `kubectl`, `helm`, etc.)
- Document commands used for verification
- No internet access for documentation (use `oc explain` and `--help`)

---

## Task 1: Project Setup (1 point)

Create a project named `exam-prod` with the following labels:
- `environment=production`
- `team=platform`

Create a ResourceQuota with these limits:
- Max 10 pods
- Max 2 CPU cores (requests)
- Max 4Gi memory (requests)

**Verification**: Show quota usage with `oc describe quota`

---

## Task 2: Deploy Application (1 point)

In `exam-prod` namespace:
1. Create a Deployment named `web` using `nginx:1.25` image
2. Set 2 replicas
3. Add label `app=web` and `tier=frontend`
4. Configure resource requests: 100m CPU, 128Mi memory
5. Configure resource limits: 200m CPU, 256Mi memory

**Verification**: All pods running, labels correct

---

## Task 3: Expose Service with TLS (1 point)

1. Expose the `web` deployment as a Service on port 80
2. Create an edge-terminated Route with:
   - Redirect HTTP to HTTPS
   - Hostname: `web-exam-prod.apps.example.com`

**Verification**: `curl -kI https://web-exam-prod.apps.example.com` returns 200

---

## Task 4: Configure Authentication (1 point)

Configure HTPasswd identity provider with these users:
- `admin1` / `admin123`
- `developer1` / `dev123`
- `viewer1` / `view123`

Grant permissions:
- `admin1`: cluster-admin
- `developer1`: admin role in `exam-prod`
- `viewer1`: view role in `exam-prod`

**Verification**: Test login and permissions with `oc auth can-i`

---

## Task 5: Network Policies (1 point)

In `exam-prod`:
1. Create a default-deny ingress policy
2. Create a policy allowing ingress to `web` pods from OpenShift Router only
3. Create a policy allowing DNS egress for all pods

**Verification**: `web` accessible via Route, but not via `oc run` test pod

---

## Task 6: Persistent Storage (1 point)

1. Create a PersistentVolumeClaim named `web-data`:
   - Size: 5Gi
   - AccessMode: ReadWriteOnce
2. Mount this PVC to `/usr/share/nginx/html` in the `web` deployment

**Verification**: PVC bound, mounted in pod

---

## Task 7: ConfigMap and Secrets (1 point)

1. Create a ConfigMap `web-config` with:
   - `index.html`: "Welcome to Exam Prod!"
2. Create a Secret `web-creds` with:
   - `admin-user`: `admin`
   - `admin-pass`: `secret123`
3. Mount ConfigMap as volume at `/usr/share/nginx/html`
4. Inject Secret as environment variables

**Verification**: `curl http://web` shows custom index.html

---

## Task 8: Autoscaling (1 point)

1. Create HorizontalPodAutoscaler for `web` deployment:
   - Min replicas: 2
   - Max replicas: 5
   - Target CPU: 70%
2. Create PodDisruptionBudget with minAvailable=1

**Verification**: HPA shows current replicas, PDB exists

---

## Task 9: SCC Management (1 point)

1. Create a Deployment `legacy-app` using `nginx` image that runs as root (uid 0)
2. Create ServiceAccount `legacy-sa`
3. Grant `anyuid` SCC to this ServiceAccount
4. Configure deployment to use this ServiceAccount

**Verification**: Pod runs with uid 0

---

## Task 10: Operator Installation (1 point)

Install the `cert-manager` Operator from community-operators:
1. Create OperatorGroup in `exam-prod`
2. Create Subscription with automatic approval
3. Wait for CSV to reach "Succeeded" phase

**Verification**: CSV shows "Succeeded"

---

## Task 11: Create Custom Resource (1 point)

Using the cert-manager Operator installed in Task 10:
1. Create a self-signed Issuer named `selfsigned`
2. Create a Certificate named `exam-cert` for `exam.example.com`
3. Verify the certificate Secret is created

**Verification**: Secret `exam-cert-tls` contains certificate

---

## Task 12: Troubleshooting (1 point)

A broken deployment `broken-app` exists in `exam-prod`. It's in ImagePullBackOff state.

Fix the issue and ensure the pod runs successfully.

**Verification**: Pod status is Running

---

## Task 13: Quota Enforcement (1 point)

The `exam-prod` namespace quota is preventing new pod creation.

1. Identify which quota limit is exceeded
2. Either delete unused resources OR increase the quota to allow 15 pods

**Verification**: Can create new pods

---

## Task 14: Node Maintenance (1 point)

1. Identify a worker node
2. Cordon the node
3. Drain the node safely (ignore DaemonSets)
4. Verify no application pods remain on the node
5. Uncordon the node

**Verification**: Node shows Ready,SchedulingEnabled

---

## Task 15: Backup and Restore (1 point)

1. Backup all resources in `exam-prod` namespace to `/tmp/exam-backup.yaml`
2. Delete the `web` deployment
3. Restore it from the backup file

**Verification**: `web` deployment restored with correct configuration

---

## Solutions

### Task 1 Solution

```bash
oc new-project exam-prod
oc label namespace exam-prod environment=production team=platform

cat <<EOF | oc apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: exam-quota
  namespace: exam-prod
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    requests.memory: "4Gi"
EOF

oc describe quota exam-quota -n exam-prod
```

### Task 2 Solution

```bash
oc create deployment web --image=nginx:1.25 --replicas=2 -n exam-prod
oc label deployment web app=web tier=frontend -n exam-prod
oc set resources deployment web \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=200m,memory=256Mi \
  -n exam-prod

oc get pods -n exam-prod --show-labels
oc describe deployment web -n exam-prod | grep -A10 Resources
```

### Task 3 Solution

```bash
oc expose deployment web --port=80 -n exam-prod
oc create route edge web \
  --service=web \
  --hostname=web-exam-prod.apps.example.com \
  --insecure-policy=Redirect \
  -n exam-prod

oc get route -n exam-prod
curl -kI https://web-exam-prod.apps.example.com
```

### Task 4 Solution

```bash
htpasswd -c -B -b /tmp/htpasswd admin1 admin123
htpasswd -b /tmp/htpasswd developer1 dev123
htpasswd -b /tmp/htpasswd viewer1 view123

oc create secret generic htpass-secret \
  --from-file=htpasswd=/tmp/htpasswd \
  -n openshift-config

oc patch oauth cluster --type=merge -p '
{
  "spec": {
    "identityProviders": [{
      "name": "htpasswd",
      "mappingMethod": "claim",
      "type": "HTPasswd",
      "htpasswd": {
        "fileData": {
          "name": "htpass-secret"
        }
      }
    }]
  }
}'

sleep 30
oc adm policy add-cluster-role-to-user cluster-admin admin1
oc adm policy add-role-to-user admin developer1 -n exam-prod
oc adm policy add-role-to-user view viewer1 -n exam-prod

oc login -u developer1 -p dev123
oc auth can-i create pods -n exam-prod  # Should return yes
oc login -u admin1 -p admin123
```

### Task 5 Solution

```bash
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: exam-prod
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-ingress
  namespace: exam-prod
spec:
  podSelector:
    matchLabels:
      app: web
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
  name: allow-dns
  namespace: exam-prod
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

oc get networkpolicy -n exam-prod
```

### Task 6 Solution

```bash
cat <<EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-data
  namespace: exam-prod
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
EOF

oc set volume deployment/web \
  --add \
  --type=persistentVolumeClaim \
  --claim-name=web-data \
  --mount-path=/usr/share/nginx/html \
  -n exam-prod

oc get pvc -n exam-prod
oc describe deployment web -n exam-prod | grep -A5 Volumes
```

### Task 7 Solution

```bash
oc create configmap web-config \
  --from-literal=index.html="Welcome to Exam Prod!" \
  -n exam-prod

oc create secret generic web-creds \
  --from-literal=admin-user=admin \
  --from-literal=admin-pass=secret123 \
  -n exam-prod

oc set volume deployment/web \
  --add \
  --type=configmap \
  --configmap-name=web-config \
  --mount-path=/usr/share/nginx/html \
  --overwrite \
  -n exam-prod

oc set env deployment/web --from=secret/web-creds -n exam-prod

oc exec deployment/web -n exam-prod -- cat /usr/share/nginx/html/index.html
```

### Task 8 Solution

```bash
oc autoscale deployment web \
  --min=2 \
  --max=5 \
  --cpu-percent=70 \
  -n exam-prod

cat <<EOF | oc apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
  namespace: exam-prod
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: web
EOF

oc get hpa -n exam-prod
oc get pdb -n exam-prod
```

### Task 9 Solution

```bash
oc create serviceaccount legacy-sa -n exam-prod
oc adm policy add-scc-to-user anyuid -z legacy-sa -n exam-prod

cat <<EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-app
  namespace: exam-prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: legacy
  template:
    metadata:
      labels:
        app: legacy
    spec:
      serviceAccountName: legacy-sa
      containers:
      - name: app
        image: nginx
        securityContext:
          runAsUser: 0
EOF

oc get pod -l app=legacy -n exam-prod -o yaml | grep runAsUser
```

### Task 10 Solution

```bash
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: exam-og
  namespace: exam-prod
spec:
  targetNamespaces:
  - exam-prod
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cert-manager
  namespace: exam-prod
spec:
  channel: stable
  name: cert-manager
  source: community-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
EOF

oc get csv -n exam-prod -w
```

### Task 11 Solution

```bash
cat <<EOF | oc apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned
  namespace: exam-prod
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: exam-cert
  namespace: exam-prod
spec:
  secretName: exam-cert-tls
  issuerRef:
    name: selfsigned
  dnsNames:
  - exam.example.com
EOF

oc get certificate -n exam-prod
oc get secret exam-cert-tls -n exam-prod
```

### Task 12 Solution

```bash
# Identify the issue
oc describe pod -l app=broken-app -n exam-prod | grep -A5 Events

# Common fixes:
# 1. Fix image name
oc set image deployment/broken-app *=nginx:1.25 -n exam-prod

# 2. Or if missing pull secret
oc set pull-secret deployment/broken-app --name=my-pull-secret -n exam-prod
```

### Task 13 Solution

```bash
# Check quota usage
oc describe quota exam-quota -n exam-prod

# Option 1: Delete unused resources
oc delete deployment legacy-app -n exam-prod

# Option 2: Increase quota
oc patch resourcequota exam-quota -n exam-prod --type=merge \
  -p '{"spec":{"hard":{"pods":"15"}}}'

# Verify
oc create deployment test --image=nginx -n exam-prod
```

### Task 14 Solution

```bash
NODE=$(oc get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[0].metadata.name}')

oc adm cordon ${NODE}
oc adm drain ${NODE} --ignore-daemonsets --delete-emptydir-data --grace-period=30
oc get pods -A -o wide | grep ${NODE}  # Should see no app pods
oc adm uncordon ${NODE}
oc get node ${NODE}  # Should show Ready
```

### Task 15 Solution

```bash
oc get all,cm,secret,pvc -n exam-prod -o yaml > /tmp/exam-backup.yaml

oc delete deployment web -n exam-prod

oc apply -f /tmp/exam-backup.yaml -n exam-prod

oc get deployment web -n exam-prod
```

---

## Scoring

- **15/15**: Excellent! Ready for certification
- **12-14**: Good! Review missed topics
- **9-11**: Fair. Practice more before exam
- **< 9**: Need more study. Review all modules

## Time Management Tips

- Read all tasks first (5 min)
- Do easy tasks first (Tasks 1-3, 15 min)
- Medium difficulty (Tasks 4-11, 30 min)
- Hard/troubleshooting last (Tasks 12-14, 10 min)

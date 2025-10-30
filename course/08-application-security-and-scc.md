# Module 08: Application Security & SCC (Security Context Constraints)

## Goals

- Understand SCCs and how they control pod security
- Select appropriate SCC for workload (restricted, nonroot, anyuid, privileged)
- Configure ServiceAccounts and bind SCCs
- Implement Pod Security Admission (PSA) modes
- Secure Secrets and ConfigMaps (encryption at rest, RBAC)
- Use SecurityContext for pod-level security hardening

## Key Terms

- **SCC (Security Context Constraint)**: OpenShift's pod security policy (predates PSA)
- **ServiceAccount**: Identity for pods to call Kubernetes API
- **PSA (Pod Security Admission)**: Kubernetes-native pod security (baseline, restricted, privileged)
- **SecurityContext**: Pod/container-level security settings (runAsUser, capabilities, readOnlyRootFilesystem)
- **RBAC for Secrets**: Control who can view/edit secrets via Roles/RoleBindings
- **Encryption at Rest**: Encrypt etcd data (secrets, configmaps) on disk

## Commands First

```bash
# List available SCCs
oc get scc
oc describe scc restricted  # Default for most pods
oc describe scc privileged  # Full host access (DANGER)

# Check which SCC a pod is using
oc get pod <pod-name> -o yaml | grep 'openshift.io/scc'
oc describe pod <pod-name> | grep 'scc'

# Create ServiceAccount
oc create serviceaccount myapp-sa -n ${NS}

# Assign SCC to ServiceAccount (DANGER: grants privileges)
oc adm policy add-scc-to-user anyuid -z myapp-sa -n ${NS}
oc adm policy add-scc-to-user privileged -z myapp-sa -n ${NS}  # Extreme caution

# Use ServiceAccount in Deployment
oc set serviceaccount deployment/myapp myapp-sa -n ${NS}

# View SCC usage
oc describe scc anyuid | grep -A10 Users

# Remove SCC from ServiceAccount
oc adm policy remove-scc-from-user anyuid -z myapp-sa -n ${NS}

# Create pod with SecurityContext
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: ${NS}
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
  - name: tmp
    emptyDir: {}
EOF

# Configure namespace Pod Security Admission
oc label namespace ${NS} \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted

# Create Secret
oc create secret generic db-creds \
  --from-literal=username=dbuser \
  --from-literal=password=dbpass123 \
  -n ${NS}

# Create ConfigMap
oc create configmap app-config \
  --from-literal=LOG_LEVEL=debug \
  --from-literal=API_URL=https://api.example.com \
  -n ${NS}

# Mount Secret as environment variables
oc set env deployment/myapp --from=secret/db-creds -n ${NS}

# Mount Secret as volume
oc set volume deployment/myapp \
  --add \
  --type=secret \
  --secret-name=db-creds \
  --mount-path=/etc/db-creds \
  -n ${NS}

# Restrict Secret access via RBAC
oc create role secret-reader \
  --verb=get,list \
  --resource=secrets \
  --resource-name=db-creds \
  -n ${NS}

oc create rolebinding dev-secret-reader \
  --role=secret-reader \
  --user=${DEV_USER} \
  -n ${NS}

# Enable encryption at rest (cluster-wide, requires cluster-admin)
# DANGER: Disruptive operation; etcd restart required
cat <<EOF | oc apply -f -
apiVersion: config.openshift.io/v1
kind: APIServer
metadata:
  name: cluster
spec:
  encryption:
    type: aescbc
EOF

# Verify encryption enabled
oc get apiserver cluster -o yaml | grep -A5 encryption
```

**Why/Notes**: SCCs prevent privilege escalation by default. Use `restricted` or `nonroot` SCCs for most apps; avoid `anyuid` and `privileged` unless absolutely necessary. ServiceAccounts enable pod-to-API communication with minimal RBAC. PSA is Kubernetes-native alternative to SCCs. Always mount secrets as volumes (not env vars) for sensitive data.

## Verify

```bash
# Check SCC assignments
oc get scc -o custom-columns=NAME:.metadata.name,USERS:.users

# Verify pod uses correct SCC
oc get pod secure-pod -o yaml | grep 'openshift.io/scc'

# Test ServiceAccount permissions
oc auth can-i get pods --as=system:serviceaccount:${NS}:myapp-sa -n ${NS}

# Verify Secret not visible to unauthorized users
oc login -u ${DEV_USER} -p dev123
oc get secret db-creds -n ${NS}  # Should fail if RBAC configured
oc login -u ${ADMIN_USER} -p admin123

# Check PSA labels
oc get namespace ${NS} -o yaml | grep pod-security
```

Expected: Pods use appropriate SCC, ServiceAccounts have minimal RBAC, Secrets protected by RBAC, PSA enforces restrictions.

## Mini-Lab (5-10 min)

**Scenario**: Deploy app requiring `anyuid` SCC (legacy app runs as root). Secure secrets with RBAC.

1. **Create app that fails with default SCC**:

```bash
oc new-project demo-scc

cat <<EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-app
  namespace: demo-scc
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
      containers:
      - name: app
        image: nginx
        securityContext:
          runAsUser: 0  # Requires root
EOF

oc get pods -n demo-scc
# Pod likely CrashLoopBackOff or fails with SCC violation
oc describe pod -l app=legacy -n demo-scc | grep -i scc
```

2. **Create ServiceAccount with anyuid SCC**:

```bash
oc create serviceaccount legacy-sa -n demo-scc
oc adm policy add-scc-to-user anyuid -z legacy-sa -n demo-scc

# Verify SCC assigned
oc describe scc anyuid | grep legacy-sa
```

3. **Update Deployment to use ServiceAccount**:

```bash
oc set serviceaccount deployment/legacy-app legacy-sa -n demo-scc

# Verify pod now runs
oc get pods -n demo-scc
oc get pod -l app=legacy -n demo-scc -o yaml | grep 'openshift.io/scc'
# Should show "anyuid"
```

4. **Create and secure secrets**:

```bash
oc create secret generic api-key \
  --from-literal=key=super-secret-123 \
  -n demo-scc

# Restrict access (only legacy-app SA can read)
oc create role api-key-reader \
  --verb=get \
  --resource=secrets \
  --resource-name=api-key \
  -n demo-scc

oc create rolebinding legacy-api-key \
  --role=api-key-reader \
  --serviceaccount=demo-scc:legacy-sa \
  -n demo-scc

# Mount secret in pod
oc set volume deployment/legacy-app \
  --add \
  --type=secret \
  --secret-name=api-key \
  --mount-path=/etc/api \
  -n demo-scc

# Verify secret mounted
oc exec -it deployment/legacy-app -n demo-scc -- cat /etc/api/key
```

5. **Apply SecurityContext hardening** (where possible):

```bash
oc patch deployment legacy-app -n demo-scc --type=merge -p '
{
  "spec": {
    "template": {
      "spec": {
        "containers": [{
          "name": "app",
          "securityContext": {
            "capabilities": {
              "drop": ["ALL"]
            }
          }
        }]
      }
    }
  }
}'

# Verify pod still runs
oc get pods -n demo-scc
```

6. **Enable PSA warnings** (doesn't block but warns on privileged pods):

```bash
oc label namespace demo-scc \
  pod-security.kubernetes.io/warn=baseline \
  pod-security.kubernetes.io/audit=baseline

# Future privileged pods will show warnings
oc get namespace demo-scc -o yaml | grep pod-security
```

## Quiz (5 Questions)

1. **Q**: What is the default SCC for pods in OpenShift?  
   **A**: `restricted` (no root, no host access, minimal capabilities).

2. **Q**: How do you grant a pod the ability to run as root?  
   **A**: Create ServiceAccount, assign `anyuid` SCC, set pod's serviceAccountName.

3. **Q**: What's the difference between SCC and PSA?  
   **A**: SCC is OpenShift-specific; PSA is Kubernetes-native pod security standard.

4. **Q**: How do you restrict who can view a secret?  
   **A**: Create Role with `get` verb on specific secret, bind via RoleBinding.

5. **Q**: Why mount secrets as volumes instead of env vars?  
   **A**: Env vars visible in `oc describe pod`; volumes are more secure and support rotation.

## Common Mistakes

- **Granting privileged SCC broadly**: Gives full host access; massive security risk.
- **Using env vars for secrets**: Visible in pod descriptions and logs; prefer volumes.
- **Not using ServiceAccounts**: Pods default to `default` SA with minimal permissions.
- **Ignoring PSA warnings**: Audit/warn modes help catch issues before enforcing.
- **Hardcoding secrets in manifests**: Always use Secret resources, not plain text YAML.

## Troubleshooting

See [Triage Matrix: SCC & Security Issues](../troubleshooting/triage-matrix.md#scc-security)

**Symptom**: Pod fails with "unable to validate against any security context constraint"  
**Triage**: `oc describe pod` shows SCC admission error  
**Fix**: Create ServiceAccount with appropriate SCC, assign to pod  
**Prevent**: Test apps in dev with default restricted SCC; request SCC exceptions judiciously

**Symptom**: Pod can't read secret (permission denied)  
**Triage**: `oc auth can-i get secret <name> --as=system:serviceaccount:<ns>:<sa>` returns "no"  
**Fix**: Create RoleBinding granting ServiceAccount access to secret  
**Prevent**: Use RBAC least privilege; only grant secrets to specific SAs

---

**Next**: [Module 09: Cluster Updates & Maintenance](09-cluster-updates-and-maintenance.md)

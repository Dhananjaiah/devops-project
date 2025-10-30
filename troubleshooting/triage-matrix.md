# OpenShift Troubleshooting Triage Matrix

## Quick Reference

| Symptom | First Command | Quick Fix |
|---------|--------------|-----------|
| Pod CrashLoopBackOff | `oc logs <pod> --previous` | Fix app error or increase resources |
| ImagePullBackOff | `oc describe pod <pod>` | Check image name/registry auth |
| Pod Pending (quota) | `oc describe quota` | Delete resources or increase quota |
| Route 503 | `oc get endpoints <svc>` | Check pod readiness probes |
| NetworkPolicy block | `oc delete networkpolicy <name>` | Add allow rule |
| SCC violation | `oc describe pod <pod>` | Create SA with appropriate SCC |

---

## <a name="declarative-management"></a>Declarative Management Issues

### Symptom: `oc apply` fails with "field immutable"

**Triage**:
```bash
oc diff -f manifest.yaml
oc describe <resource> <name>
```

**Likely Root Causes**:
- Service clusterIP or type changed
- StatefulSet volumeClaimTemplate modified
- Deployment selector changed

**Fix**:
```bash
# Delete and recreate (DANGER: downtime)
oc delete -f manifest.yaml
oc apply -f manifest.yaml

# OR use replace --force
oc replace --force -f manifest.yaml
```

**Prevent**:
- Test changes in dev first
- Use `oc diff` before applying
- Review K8s docs for immutable fields

---

### Symptom: Kustomize overlay doesn't apply patches

**Triage**:
```bash
kustomize build overlays/dev  # Preview output
oc kustomize overlays/dev | less  # Check generated YAML
```

**Likely Root Causes**:
- Wrong patch path or target selector
- Typo in resource name
- Missing base resource

**Fix**:
```yaml
# Correct patch syntax
patches:
- target:
    kind: Deployment
    name: myapp
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
```

**Prevent**:
- Test with `kustomize build` before `oc apply -k`
- Use strategic merge patches for simpler changes

---

## <a name="packaged-apps"></a>Packaged App Issues

### Symptom: Helm install fails with "forbidden: User cannot create resource"

**Triage**:
```bash
helm template <name> <chart> --debug
oc auth can-i create clusterrole
```

**Likely Root Causes**:
- Chart creates ClusterRole/CRDs (requires cluster-admin)
- RBAC restrictions for namespace

**Fix**:
```bash
# Install as cluster-admin
oc login -u admin

# OR use --set to disable RBAC creation
helm install <name> <chart> --set rbac.create=false
```

**Prevent**:
- Review chart with `helm show values` first
- Use `--dry-run` flag

---

### Symptom: ImageStream shows "Internal error occurred: Pull through manifest failed"

**Triage**:
```bash
oc describe imagestream <name>
oc get secret -n openshift-config | grep pull-secret
```

**Likely Root Causes**:
- Registry authentication failed
- Image doesn't exist
- Network connectivity issue

**Fix**:
```bash
# Update pull secret
oc set data secret/pull-secret -n openshift-config \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json

# OR import image manually
oc import-image <name>:<tag> --from=<registry>/<image>:<tag> --confirm
```

**Prevent**:
- Test `oc import-image` with `--confirm` first
- Verify registry connectivity

---

## <a name="auth-rbac"></a>Authentication & RBAC Issues

### Symptom: User login fails with "invalid username or password"

**Triage**:
```bash
oc get oauth cluster -o yaml
oc get secret -n openshift-config | grep htpass
```

**Likely Root Causes**:
- HTPasswd secret doesn't exist
- OAuth pod not restarted after secret update
- Wrong username/password in htpasswd file

**Fix**:
```bash
# Recreate htpasswd secret
htpasswd -c -B -b /tmp/htpasswd admin admin123
oc create secret generic htpass-secret \
  --from-file=htpasswd=/tmp/htpasswd \
  -n openshift-config \
  --dry-run=client -o yaml | oc replace -f -

# Wait for OAuth pods to restart
oc get pods -n openshift-authentication -w
```

**Prevent**:
- Test with `htpasswd -v /tmp/htpasswd <user>` before creating secret
- Wait 30-60s after secret update

---

### Symptom: `oc auth can-i` returns "no" but user claims they have access

**Triage**:
```bash
oc get rolebindings,clusterrolebindings -A | grep <user>
oc describe rolebinding <name> -n <namespace>
```

**Likely Root Causes**:
- No RoleBinding exists for user
- RoleBinding references wrong Role
- User in wrong group

**Fix**:
```bash
# Grant access
oc adm policy add-role-to-user admin <user> -n <namespace>

# Or via RoleBinding
oc create rolebinding <name> \
  --role=edit \
  --user=<user> \
  -n <namespace>
```

**Prevent**:
- Use groups instead of individual users
- Document RBAC changes
- Test with `--as` flag

---

## <a name="network-security"></a>Route & NetworkPolicy Issues

### Symptom: Route returns 503 Service Unavailable

**Triage**:
```bash
oc get route <name>
oc get endpoints <service>  # Should show pod IPs
oc get pods -l <selector>
```

**Likely Root Causes**:
- No ready pods behind service
- Service selector doesn't match pod labels
- NetworkPolicy blocks ingress from router

**Fix**:
```bash
# Check pod readiness
oc describe pod <name> | grep -A10 Conditions

# Fix service selector
oc set selector service/<name> app=myapp

# Verify NetworkPolicy allows ingress
oc get networkpolicy
```

**Prevent**:
- Use `oc status` to verify service→pod linkage
- Test routes after creating NetworkPolicies

---

### Symptom: Pod can't reach external services after NetworkPolicy applied

**Triage**:
```bash
oc exec <pod> -- curl -m 5 http://example.com
oc exec <pod> -- nslookup example.com
oc get networkpolicy
```

**Likely Root Causes**:
- Egress blocked by default-deny policy
- DNS egress not allowed
- No internet egress policy

**Fix**:
```yaml
# Allow DNS egress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
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
  # Add internet egress if needed
  - to:
    - podSelector: {}
```

**Prevent**:
- Always allow DNS egress in production
- Start with ingress-only policies

---

## <a name="service-connectivity"></a>Service Connectivity Issues

### Symptom: NodePort service not accessible externally

**Triage**:
```bash
oc get svc <name>
telnet <node-ip> <node-port>
oc get networkpolicy
```

**Likely Root Causes**:
- Firewall blocks node ports
- Security group doesn't allow traffic
- NetworkPolicy blocks node port

**Fix**:
```bash
# Check cloud security group (AWS example)
aws ec2 describe-security-groups --group-ids <sg-id>

# Update to allow nodePort range (30000-32767)
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> \
  --protocol tcp \
  --port 30000-32767 \
  --cidr 0.0.0.0/0
```

**Prevent**:
- Use Routes instead of NodePort in production
- Document required firewall rules

---

### Symptom: LoadBalancer EXTERNAL-IP stuck in Pending

**Triage**:
```bash
oc describe svc <name>
oc get events | grep <name>
```

**Likely Root Causes**:
- No cloud provider LB controller
- No MetalLB in on-prem
- Quota exceeded

**Fix**:
```bash
# Check cloud provider integration
oc get clusteroperators

# For on-prem, install MetalLB
oc apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.0/config/manifests/metallb-native.yaml
```

**Prevent**:
- Use NodePort or Routes if LB not available
- Verify cloud provider support before using LoadBalancer

---

## <a name="quota-limits"></a>Quota & Limit Issues

### Symptom: Pod stuck in Pending with "exceeded quota"

**Triage**:
```bash
oc describe pod <pod>
oc describe resourcequota -n <namespace>
```

**Likely Root Causes**:
- ResourceQuota hard limit reached
- Pod requests exceed quota
- Too many pods/PVCs/services

**Fix**:
```bash
# Delete unused resources
oc delete deployment <unused> -n <namespace>

# OR increase quota
oc patch resourcequota <name> -n <namespace> --type=merge \
  -p '{"spec":{"hard":{"pods":"20","requests.cpu":"4"}}}'
```

**Prevent**:
- Monitor quota usage: `oc describe quota`
- Set alerts at 80% threshold
- Use LimitRange with sensible defaults

---

### Symptom: New project missing quotas/limits from template

**Triage**:
```bash
oc get resourcequota,limitrange -n <project>
oc get project.config.openshift.io cluster -o yaml
```

**Likely Root Causes**:
- Project request template not configured
- Template has syntax error
- Existing projects unaffected by template changes

**Fix**:
```bash
# Verify template configuration
oc get template project-request -n openshift-config -o yaml

# Manually apply quotas to existing project
oc apply -f quotas.yaml -n <project>
```

**Prevent**:
- Test template changes in dev cluster
- Document that existing projects aren't updated

---

## <a name="olm"></a>OLM (Operator) Issues

### Symptom: CSV stuck in "Installing" phase

**Triage**:
```bash
oc describe csv <name> -n <namespace>
oc get installplan -n <namespace>
oc logs <operator-pod> -n <namespace>
```

**Likely Root Causes**:
- Missing OperatorGroup
- RBAC insufficient for operator
- Dependency operator not installed

**Fix**:
```bash
# Create OperatorGroup if missing
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: <name>
  namespace: <namespace>
spec:
  targetNamespaces:
  - <namespace>
EOF

# Check and approve InstallPlan if manual
oc patch installplan <name> -n <namespace> \
  --type=merge -p '{"spec":{"approved":true}}'
```

**Prevent**:
- Always create OperatorGroup for namespace-scoped operators
- Review operator docs for prerequisites

---

### Symptom: CR not reconciling (stuck in "Unknown" state)

**Triage**:
```bash
oc describe <crd> <cr-name> -n <namespace>
oc logs <operator-pod> -n <namespace>
```

**Likely Root Causes**:
- CR spec validation error
- Operator bug/crash
- Missing required fields

**Fix**:
```bash
# Check CRD schema
oc explain <crd>.spec

# Fix CR spec
oc edit <crd> <cr-name> -n <namespace>

# Restart operator if crashed
oc delete pod <operator-pod> -n <namespace>
```

**Prevent**:
- Use `oc explain` to understand CRD schema
- Test CRs in dev before prod

---

## <a name="scc-security"></a>SCC & Security Issues

### Symptom: Pod fails with "unable to validate against any security context constraint"

**Triage**:
```bash
oc describe pod <pod>
oc get scc
oc get pod <pod> -o yaml | grep serviceAccountName
```

**Likely Root Causes**:
- Pod requires root or privileged access
- ServiceAccount doesn't have SCC
- SecurityContext violates restricted SCC

**Fix**:
```bash
# Create ServiceAccount with anyuid (DANGER: grants root)
oc create serviceaccount <sa-name> -n <namespace>
oc adm policy add-scc-to-user anyuid -z <sa-name> -n <namespace>

# Update pod to use SA
oc set serviceaccount deployment/<name> <sa-name> -n <namespace>
```

**Prevent**:
- Test apps with restricted SCC first
- Request SCC exceptions judiciously
- Document why elevated SCC is needed

---

### Symptom: Pod can't read secret (permission denied)

**Triage**:
```bash
oc auth can-i get secret <name> \
  --as=system:serviceaccount:<namespace>:<sa> \
  -n <namespace>
oc describe rolebinding -n <namespace>
```

**Likely Root Causes**:
- ServiceAccount doesn't have RBAC
- Secret in different namespace
- RoleBinding references wrong SA

**Fix**:
```bash
# Grant ServiceAccount access to secret
oc create role secret-reader \
  --verb=get \
  --resource=secrets \
  --resource-name=<secret-name> \
  -n <namespace>

oc create rolebinding <binding-name> \
  --role=secret-reader \
  --serviceaccount=<namespace>:<sa> \
  -n <namespace>
```

**Prevent**:
- Use RBAC least privilege
- Test SA permissions with `oc auth can-i --as`

---

## <a name="cluster-maintenance"></a>Cluster Maintenance Issues

### Symptom: Cluster upgrade stuck "Progressing"

**Triage**:
```bash
oc get clusterversion
oc get clusteroperators | grep -v 'True.*False.*False'
oc describe co <degraded-operator>
```

**Likely Root Causes**:
- Operator degraded or unavailable
- Node not ready
- Etcd backup failed

**Fix**:
```bash
# Fix degraded operator (example: image-registry)
oc edit configs.imageregistry.operator.openshift.io cluster
# Configure storage backend

# Check node issues
oc get nodes
oc describe node <node>

# Restart operator if stuck
oc delete pod -n openshift-<operator-namespace> -l app=<operator>
```

**Prevent**:
- Ensure all operators healthy before upgrade
- Review release notes for breaking changes

---

### Symptom: Node drain hangs indefinitely

**Triage**:
```bash
oc get pods -A -o wide | grep <node>
oc describe pod <stuck-pod>
```

**Likely Root Causes**:
- PodDisruptionBudget blocks eviction
- Pod has local storage
- Pod stuck in Terminating

**Fix**:
```bash
# Force delete stuck pod (DANGER: potential data loss)
oc delete pod <pod> --grace-period=0 --force

# Temporarily scale down Deployment with PDB
oc scale deployment <name> --replicas=0

# Complete drain
oc adm drain <node> --ignore-daemonsets --delete-emptydir-data --force
```

**Prevent**:
- Use PDBs wisely (minAvailable=1, not 100%)
- Avoid local storage without backups
- Set reasonable grace periods

---

## General Troubleshooting Workflow

1. **Identify Symptom**: What is failing? (Pod, Route, Service, etc.)
2. **Triage Commands**:
   ```bash
   oc get <resource>
   oc describe <resource> <name>
   oc logs <pod> [--previous]
   oc get events --sort-by='.lastTimestamp'
   ```
3. **Root Cause Analysis**: Match symptom to this matrix
4. **Apply Fix**: Use commands from "Fix" section
5. **Verify**: Confirm issue resolved
6. **Document**: Update runbook with lessons learned
7. **Prevent**: Implement monitoring/alerts to catch early

---

## Emergency Contacts

- **Platform Team**: platform@example.com
- **Red Hat Support**: https://access.redhat.com/support
- **Community**: #openshift on Kubernetes Slack

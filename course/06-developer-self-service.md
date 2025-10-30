# Module 06: Developer Self-Service

## Goals

- Configure ResourceQuotas to limit namespace resource consumption
- Apply LimitRanges for default/min/max pod resource requests
- Customize project request templates for new projects
- Manage self-provisioner role safely (allow/deny project creation)
- Implement chargeback via resource tracking
- Balance developer autonomy with cluster stability

## Key Terms

- **ResourceQuota**: Hard limits on total resources in namespace (CPU, memory, pods, PVCs)
- **LimitRange**: Default/min/max resource limits for individual pods/containers
- **Project Request Template**: Custom template applied to new projects (quotas, limits, RBAC)
- **Self-Provisioner**: ClusterRole allowing users to create projects
- **Chargeback**: Track resource usage for billing/accountability
- **PriorityClass**: Pod scheduling priority (higher = scheduled first)

## Commands First

```bash
# Create ResourceQuota
cat <<EOF | oc apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: ${NS}
spec:
  hard:
    requests.cpu: "4"
    requests.memory: "8Gi"
    limits.cpu: "8"
    limits.memory: "16Gi"
    pods: "20"
    persistentvolumeclaims: "5"
    services: "10"
EOF

# Create LimitRange (defaults for pods without requests/limits)
cat <<EOF | oc apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limits
  namespace: ${NS}
spec:
  limits:
  - type: Pod
    max:
      cpu: "2"
      memory: "4Gi"
    min:
      cpu: "50m"
      memory: "64Mi"
  - type: Container
    default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "2"
      memory: "4Gi"
    min:
      cpu: "50m"
      memory: "64Mi"
EOF

# View quota usage
oc get resourcequota -n ${NS}
oc describe resourcequota dev-quota -n ${NS}

# View LimitRange
oc get limitrange -n ${NS}
oc describe limitrange dev-limits -n ${NS}

# Check current resource consumption
oc adm top nodes
oc adm top pods -n ${NS}

# Disable self-provisioner (users cannot create projects)
oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth

# Enable self-provisioner (restore default)
oc adm policy add-cluster-role-to-group self-provisioner system:authenticated:oauth

# Create custom project request template
oc adm create-bootstrap-project-template -o yaml > /tmp/project-template.yaml

# Edit template to add quotas, limits, RBAC
cat <<'EOF' >> /tmp/project-template.yaml
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: default-quota
spec:
  hard:
    requests.cpu: "2"
    requests.memory: "4Gi"
    limits.cpu: "4"
    limits.memory: "8Gi"
    pods: "10"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
spec:
  limits:
  - type: Container
    default:
      cpu: "200m"
      memory: "256Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
EOF

# Apply custom template
oc create -f /tmp/project-template.yaml -n openshift-config

# Configure cluster to use template
oc patch project.config.openshift.io/cluster \
  --type=merge \
  -p '{"spec":{"projectRequestTemplate":{"name":"project-request"}}}'

# Test: Create new project and verify quotas applied
oc new-project test-quota
oc get resourcequota,limitrange -n test-quota

# Create PriorityClass for critical workloads
cat <<EOF | oc apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "High priority for critical apps"
EOF

# Use PriorityClass in deployment
oc set priorityclass deployment/critical-app high-priority -n ${NS}
```

**Why/Notes**: Quotas prevent noisy neighbors. LimitRanges enforce sensible defaults. Disabling self-provisioner + project templates enables controlled onboarding. PriorityClasses ensure critical workloads preempt low-priority pods.

## Verify

```bash
# Verify quotas enforced
oc describe resourcequota dev-quota -n ${NS}
# Check "Used" vs "Hard" limits

# Test quota enforcement (should fail if quota exceeded)
oc run quota-test --image=nginx -n ${NS} \
  --requests='cpu=5,memory=10Gi'  # Exceeds quota
# Should see: "exceeded quota: dev-quota"

# Verify LimitRange defaults applied
oc run limit-test --image=nginx -n ${NS}
oc get pod limit-test -n ${NS} -o yaml | grep -A5 resources
# Should show default requests/limits

# Check template applied to new projects
oc new-project template-test
oc get resourcequota,limitrange -n template-test
```

Expected: Quotas limit resource creation, LimitRanges apply defaults, new projects inherit template config.

## Mini-Lab (5-10 min)

**Scenario**: Create dev and prod projects with different quotas/limits. Disable self-provisioner. Apply custom template.

1. **Create dev project with low quotas**:

```bash
oc new-project demo-dev-quota

cat <<EOF | oc apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: demo-dev-quota
spec:
  hard:
    requests.cpu: "2"
    requests.memory: "4Gi"
    limits.cpu: "4"
    limits.memory: "8Gi"
    pods: "10"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limits
  namespace: demo-dev-quota
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
      memory: "2Gi"
EOF
```

2. **Create prod project with higher quotas**:

```bash
oc new-project demo-prod-quota

cat <<EOF | oc apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: demo-prod-quota
spec:
  hard:
    requests.cpu: "8"
    requests.memory: "16Gi"
    limits.cpu: "16"
    limits.memory: "32Gi"
    pods: "50"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: prod-limits
  namespace: demo-prod-quota
spec:
  limits:
  - type: Container
    default:
      cpu: "1"
      memory: "1Gi"
    defaultRequest:
      cpu: "500m"
      memory: "512Mi"
    max:
      cpu: "4"
      memory: "8Gi"
EOF
```

3. **Test quota enforcement**:

```bash
# Deploy within limits (dev)
oc create deployment nginx-ok --image=nginx --replicas=2 -n demo-dev-quota
oc get pods -n demo-dev-quota

# Try to exceed quota
oc create deployment nginx-fail --image=nginx --replicas=20 -n demo-dev-quota
# Some pods will stay Pending due to quota

oc describe resourcequota dev-quota -n demo-dev-quota
# Shows "Used" approaching "Hard" limits

# Delete failing deployment
oc delete deployment nginx-fail -n demo-dev-quota
```

4. **Disable self-provisioner**:

```bash
# Remove self-provisioner from authenticated users
oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth

# Test as non-admin user (should fail)
oc login -u ${DEV_USER} -p dev123
oc new-project should-fail
# Error: "You may not request a new project via this API"

# Restore admin session
oc login -u ${ADMIN_USER} -p admin123
```

5. **Create and apply custom template**:

```bash
# Generate base template
oc adm create-bootstrap-project-template -o yaml > /tmp/custom-template.yaml

# Add custom quotas to template (edit in place)
cat <<'TEMPLATE_EOF' >> /tmp/custom-template.yaml
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: auto-quota
  spec:
    hard:
      requests.cpu: "1"
      requests.memory: "2Gi"
      pods: "5"
- apiVersion: v1
  kind: LimitRange
  metadata:
    name: auto-limits
  spec:
    limits:
    - type: Container
      default:
        cpu: "200m"
        memory: "256Mi"
      defaultRequest:
        cpu: "100m"
        memory: "128Mi"
TEMPLATE_EOF

# Create template in openshift-config
oc create -f /tmp/custom-template.yaml -n openshift-config

# Configure cluster to use it
oc patch project.config.openshift.io/cluster --type=merge \
  -p '{"spec":{"projectRequestTemplate":{"name":"project-request"}}}'

# Wait and test
sleep 30
oc new-project template-verify
oc get resourcequota,limitrange -n template-verify
# Should show auto-quota and auto-limits
```

## Quiz (5 Questions)

1. **Q**: What's the difference between ResourceQuota and LimitRange?  
   **A**: Quota limits total namespace resources; LimitRange sets defaults/min/max per pod/container.

2. **Q**: How do you prevent users from creating projects?  
   **A**: Remove self-provisioner role: `oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth`

3. **Q**: What happens if a pod exceeds LimitRange max values?  
   **A**: Pod creation is rejected with "exceeded LimitRange" error.

4. **Q**: How do you apply custom quotas to all new projects?  
   **A**: Create project request template with quotas; configure in `project.config.openshift.io/cluster`.

5. **Q**: What is PriorityClass used for?  
   **A**: Define pod scheduling priority; higher priority pods preempt lower priority ones.

## Common Mistakes

- **Quota without LimitRange**: Pods without requests/limits can't be scheduled (quota can't track unbounded resources).
- **Removing self-provisioner globally**: Blocks all users; grant exceptions via `oc adm policy add-role-to-user admin <user>`.
- **Template changes not applied**: Existing projects unaffected; only new projects get template.
- **Quotas too restrictive**: Prevents legitimate workloads; monitor usage and adjust.
- **Not setting defaultRequest**: Pods without requests get zero CPU, starved by scheduler.

## Troubleshooting

See [Triage Matrix: Quota & Limit Issues](../troubleshooting/triage-matrix.md#quota-limits)

**Symptom**: Pod stuck in Pending with "exceeded quota"  
**Triage**: `oc describe pod` shows quota error; `oc describe quota` shows usage at limit  
**Fix**: Delete unused resources or increase quota  
**Prevent**: Monitor quota usage; set alerts at 80% threshold

**Symptom**: New project missing quotas/limits from template  
**Triage**: `oc get resourcequota,limitrange -n <project>` empty  
**Fix**: Verify `project.config.openshift.io/cluster` has correct `projectRequestTemplate`  
**Prevent**: Test template changes in dev cluster first

---

**Next**: [Module 07: Operators & OLM](07-operators-and-olm.md)

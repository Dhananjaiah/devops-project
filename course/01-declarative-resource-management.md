# Module 01: Declarative Resource Management

## Goals

- Master `oc apply` for declarative resource lifecycle
- Use labels and annotations for resource organization
- Leverage `oc diff` and `--dry-run=server` for safe changes
- Build multi-environment deployments with Kustomize overlays
- Understand Projects vs Namespaces in OpenShift
- Debug resource states with `oc get -o yaml` and `oc describe`

## Key Terms

- **Declarative**: Define desired state; cluster reconciles to match
- **Imperative**: Execute commands that directly change cluster state
- **Project**: OpenShift construct wrapping Kubernetes namespace with RBAC defaults
- **Label**: Key-value pair for grouping/selecting resources (e.g., `app=web`)
- **Annotation**: Metadata for tools/humans; not used for selection (e.g., `description="Frontend service"`)
- **Kustomize**: Native Kubernetes config management using overlays and patches
- **Dry-run**: Preview changes without applying them to cluster

## Commands First

```bash
# Create project (OpenShift) vs namespace (Kubernetes)
oc new-project ${NS}  # Creates project with RBAC defaults
oc create namespace ${NS}  # Plain namespace without OpenShift defaults

# Apply declarative manifests
oc apply -f deployment.yaml
oc apply -f ./manifests/  # Apply directory
oc apply -k ./overlays/dev  # Apply Kustomize overlay

# Preview changes before applying (dry-run)
oc apply -f deployment.yaml --dry-run=client -o yaml  # Client-side validation
oc apply -f deployment.yaml --dry-run=server -o yaml  # Server-side validation

# Diff against current state
oc diff -f deployment.yaml  # Shows unified diff
oc diff -k ./overlays/prod

# Get resources with labels
oc get pods -l app=nginx
oc get all -l environment=production
oc get pods -l 'app in (web,api)'  # Set-based selector

# Add/update labels and annotations
oc label pod nginx-pod version=1.2.0
oc label pod nginx-pod version-  # Remove label
oc annotate deployment nginx description="Main web server"

# Inspect resources
oc get deployment nginx -o yaml  # Full resource YAML
oc get deployment nginx -o json | jq '.spec.replicas'  # Extract specific field
oc describe pod nginx-pod-abc123  # Human-readable details + events

# Export clean resource (no status/metadata clutter)
oc get deployment nginx -o yaml --export  # Deprecated in 1.18+
oc get deployment nginx -o yaml | yq 'del(.status, .metadata.uid, .metadata.resourceVersion)'  # Clean export

# Delete declaratively
oc delete -f deployment.yaml
oc delete -k ./overlays/dev
```

**Why/Notes**: Declarative management (`apply`) is idempotent and safer than imperative (`create`, `replace`). Server-side dry-run catches validation errors early. Kustomize avoids config duplication across environments.

## Verify

```bash
# Confirm project exists
oc project ${NS}
oc get project ${NS}

# Verify applied resources
oc get all -n ${NS}
oc get deployment,svc,route -l app=myapp

# Check labels and annotations
oc get pods --show-labels
oc describe deployment myapp | grep -E 'Labels|Annotations'

# Test Kustomize overlay
kustomize build ./overlays/dev  # Preview generated manifests
oc kustomize ./overlays/prod | oc diff -f -  # Diff without applying
```

Expected: Project created, resources deployed, labels applied, diffs show no changes on re-apply.

## Mini-Lab (5-10 min)

**Scenario**: Deploy an nginx app with dev and prod Kustomize overlays. Dev uses 1 replica; prod uses 3 replicas with resource limits.

1. **Create base manifests**:

```bash
mkdir -p ~/lab01/{base,overlays/dev,overlays/prod}
cd ~/lab01/base

cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

cat <<EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
EOF

cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
EOF
```

2. **Create dev overlay**:

```bash
cd ~/lab01/overlays/dev

cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: demo-dev
namePrefix: dev-
commonLabels:
  environment: dev
resources:
- ../../base
replicas:
- name: nginx
  count: 1
EOF
```

3. **Create prod overlay**:

```bash
cd ~/lab01/overlays/prod

cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: demo-prod
namePrefix: prod-
commonLabels:
  environment: prod
resources:
- ../../base
replicas:
- name: nginx
  count: 3
patches:
- patch: |-
    - op: add
      path: /spec/template/spec/containers/0/resources
      value:
        requests:
          memory: "128Mi"
          cpu: "250m"
        limits:
          memory: "256Mi"
          cpu: "500m"
  target:
    kind: Deployment
    name: nginx
EOF
```

4. **Apply overlays**:

```bash
oc new-project demo-dev
oc apply -k ~/lab01/overlays/dev

oc new-project demo-prod
oc apply -k ~/lab01/overlays/prod
```

5. **Verify**:

```bash
oc get deploy,svc -n demo-dev --show-labels
oc get deploy,svc -n demo-prod --show-labels
oc get pods -n demo-dev  # Should see 1 dev-nginx pod
oc get pods -n demo-prod  # Should see 3 prod-nginx pods
oc describe deploy prod-nginx -n demo-prod | grep -A5 Limits
```

Expected output: Dev has 1 replica, prod has 3 replicas with resource limits. Labels include `environment=dev` and `environment=prod`.

6. **Test diff and dry-run**:

```bash
# Edit base replicas to 2
sed -i 's/replicas: 1/replicas: 2/' ~/lab01/base/deployment.yaml

# Preview changes
oc diff -k ~/lab01/overlays/dev  # Shows dev will change to 2 (but overlay overrides it)
oc apply -k ~/lab01/overlays/dev --dry-run=server  # Server validates

# Revert change
sed -i 's/replicas: 2/replicas: 1/' ~/lab01/base/deployment.yaml
```

## Quiz (5 Questions)

1. **Q**: What's the difference between `oc create` and `oc apply`?  
   **A**: `create` fails if resource exists; `apply` updates existing or creates new (idempotent).

2. **Q**: How do you preview changes before applying a manifest?  
   **A**: Use `oc apply --dry-run=server -f manifest.yaml` or `oc diff -f manifest.yaml`.

3. **Q**: What's the difference between a label and an annotation?  
   **A**: Labels are for selecting/grouping; annotations are for metadata (tools, descriptions).

4. **Q**: How does Kustomize avoid config duplication?  
   **A**: Base manifests + overlays (patches, replicas, namespaces) per environment.

5. **Q**: What command removes a label from a pod?  
   **A**: `oc label pod <name> <key>-` (note trailing dash).

## Common Mistakes

- **Using `oc create` repeatedly**: Fails on re-run. Use `oc apply` for idempotence.
- **Forgetting `--namespace`**: Operations default to current project. Always specify or switch with `oc project`.
- **Not using `--dry-run=server`**: Client-side validation misses API/webhook errors.
- **Editing resources with `oc edit`**: Changes are imperative. Use declarative YAML files for version control.
- **Label selector typos**: `app==nginx` (double equals) is wrong; use `app=nginx`.

## Troubleshooting

See [Triage Matrix: Declarative Management Issues](../troubleshooting/triage-matrix.md#declarative-management)

**Symptom**: `oc apply` fails with "field immutable"  
**Triage**: `oc diff -f manifest.yaml` shows prohibited change (e.g., service type)  
**Fix**: Delete and recreate resource, or use strategic merge patch  
**Prevent**: Test changes in dev before prod; review immutable fields in docs

**Symptom**: Kustomize overlay doesn't override base values  
**Triage**: `kustomize build overlays/dev` shows base values  
**Fix**: Ensure overlay has correct `patches` or `replicas` section  
**Prevent**: Test with `kustomize build` before `oc apply -k`

---

**Next**: [Module 02: Deploy Packaged Applications](02-deploy-packaged-apps.md)

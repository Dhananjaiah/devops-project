# Module 02: Deploy Packaged Applications

## Goals

- Deploy apps from OpenShift Templates with parameters
- Understand ImageStreams and BuildConfigs basics
- Install and customize Helm charts on OpenShift
- Manage Helm releases (install, upgrade, rollback)
- Convert templates to standard manifests for GitOps
- Use `helm template` for dry-run previews

## Key Terms

- **Template**: OpenShift's parameterized YAML format (predates Helm)
- **ImageStream**: Abstraction layer over container images; tracks tags and notifies on updates
- **BuildConfig**: Defines how to build container images (S2I, Docker, custom)
- **Helm Chart**: Package of Kubernetes manifests with templating (values.yaml)
- **Helm Release**: Deployed instance of a chart with specific values
- **S2I (Source-to-Image)**: OpenShift build strategy from source code to image

## Commands First

```bash
# List available templates in openshift namespace
oc get templates -n openshift
oc describe template mysql-persistent -n openshift

# Process template with parameters (preview)
oc process mysql-persistent \
  -p MYSQL_USER=dbuser \
  -p MYSQL_PASSWORD=dbpass123 \
  -p MYSQL_DATABASE=sampledb \
  -n openshift

# Deploy from template
oc new-app --template=mysql-persistent \
  -p MYSQL_USER=dbuser \
  -p MYSQL_PASSWORD=dbpass123 \
  -p MYSQL_DATABASE=sampledb \
  -n ${NS}

# Export processed template to YAML (for GitOps)
oc process mysql-persistent -n openshift \
  -p MYSQL_USER=dbuser \
  -p MYSQL_PASSWORD=dbpass123 \
  -p MYSQL_DATABASE=sampledb \
  -o yaml > mysql-deployment.yaml

# Create ImageStream manually
oc create imagestream myapp -n ${NS}
oc import-image myapp:1.0 --from=${REGISTRY}/myapp:1.0 --confirm

# Trigger new build (if BuildConfig exists)
oc start-build myapp-bc
oc logs -f bc/myapp-bc  # Follow build logs

# Helm repository management
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/postgresql

# Inspect Helm chart
helm show chart bitnami/postgresql
helm show values bitnami/postgresql > values.yaml

# Install Helm chart
helm install my-postgres bitnami/postgresql \
  --namespace ${NS} \
  --set auth.username=pguser \
  --set auth.password=pgpass123 \
  --set auth.database=mydb \
  --set primary.persistence.size=5Gi

# Upgrade Helm release
helm upgrade my-postgres bitnami/postgresql \
  --namespace ${NS} \
  --reuse-values \
  --set primary.persistence.size=10Gi

# Rollback Helm release
helm rollback my-postgres 1 -n ${NS}  # Rollback to revision 1
helm history my-postgres -n ${NS}

# Template Helm chart without installing (dry-run)
helm template my-postgres bitnami/postgresql \
  --namespace ${NS} \
  --set auth.username=pguser \
  --set auth.database=mydb

# List and delete Helm releases
helm list -n ${NS}
helm uninstall my-postgres -n ${NS}
```

**Why/Notes**: Templates are OpenShift-native but less flexible than Helm. ImageStreams enable automated deployments on base image updates. Helm is the Kubernetes standard for app packaging. Use `helm template` for GitOps workflows.

## Verify

```bash
# Check template deployment
oc get all -l app=mysql-persistent -n ${NS}
oc get pvc -n ${NS}  # Verify persistent storage created

# Verify ImageStream
oc get is -n ${NS}
oc describe is myapp -n ${NS}

# Check Helm release
helm status my-postgres -n ${NS}
oc get all -l app.kubernetes.io/instance=my-postgres -n ${NS}
oc get secret --field-selector type=helm.sh/release.v1 -n ${NS}  # Helm secrets

# Test database connection
oc run psql-test --image=postgres:15 --rm -it --restart=Never -n ${NS} -- \
  psql -h my-postgres-postgresql -U pguser -d mydb -c '\l'
```

Expected: Template resources created, ImageStreams track tags, Helm release deployed with custom values.

## Mini-Lab (5-10 min)

**Scenario**: Deploy PostgreSQL using a Helm chart, then upgrade storage size.

1. **Add Helm repo and search**:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo postgresql
helm show values bitnami/postgresql | grep -A2 persistence
```

2. **Create namespace and install**:

```bash
oc new-project demo-helm
helm install lab-db bitnami/postgresql \
  --namespace demo-helm \
  --set auth.username=labuser \
  --set auth.password=lab123pass \
  --set auth.database=labdb \
  --set primary.persistence.size=2Gi \
  --set primary.resources.requests.memory=256Mi
```

3. **Verify deployment**:

```bash
helm status lab-db -n demo-helm
oc get pods -n demo-helm -l app.kubernetes.io/instance=lab-db
oc get pvc -n demo-helm
oc get secret lab-db-postgresql -n demo-helm -o yaml | grep password: | awk '{print $2}' | base64 -d
```

Expected: PostgreSQL pod running, PVC bound to 2Gi volume, secret contains password.

4. **Upgrade storage**:

```bash
helm upgrade lab-db bitnami/postgresql \
  --namespace demo-helm \
  --reuse-values \
  --set primary.persistence.size=5Gi

helm history lab-db -n demo-helm
oc get pvc -n demo-helm  # Size still 2Gi (PVCs don't auto-expand)
```

Note: PVC resizing requires manual `oc patch` or storage class support for expansion.

5. **Rollback and cleanup**:

```bash
helm rollback lab-db 1 -n demo-helm
helm list -n demo-helm
helm uninstall lab-db -n demo-helm
oc delete project demo-helm
```

## Quiz (5 Questions)

1. **Q**: What's the difference between OpenShift Templates and Helm charts?  
   **A**: Templates are OpenShift-specific; Helm is Kubernetes-native and more feature-rich.

2. **Q**: How do you preview Helm chart manifests without installing?  
   **A**: `helm template <name> <chart> --set key=value`

3. **Q**: What does an ImageStream do?  
   **A**: Abstracts image references, tracks tags, and triggers deployments on image updates.

4. **Q**: How do you rollback a Helm release?  
   **A**: `helm rollback <release> <revision> -n <namespace>`

5. **Q**: Can you edit a template-deployed resource and preserve changes?  
   **A**: No. Re-processing template overwrites manual edits. Export to YAML and use `oc apply`.

## Common Mistakes

- **Forgetting `--reuse-values`**: Upgrade without this flag resets all values to chart defaults.
- **Not using `helm template` first**: Direct install can fail; dry-run catches errors early.
- **Mixing `oc` and Helm**: Deleting pods manually confuses Helm's state tracking.
- **ImageStream tag confusion**: `latest` tag may point to old SHA; use digest for reproducibility.
- **Template parameter typos**: `oc process` silently ignores invalid params; check with `-o yaml`.

## Troubleshooting

See [Triage Matrix: Packaged App Issues](../troubleshooting/triage-matrix.md#packaged-apps)

**Symptom**: Helm install fails with "forbidden: User cannot create resource"  
**Triage**: `helm template` shows RBAC-restricted resources (ClusterRole, etc.)  
**Fix**: Install with cluster-admin or adjust chart's RBAC templates  
**Prevent**: Review chart permissions before install; use `--dry-run` flag

**Symptom**: ImageStream shows "Internal error occurred: Pull through manifest failed"  
**Triage**: `oc describe is <name>` shows auth or network error  
**Fix**: Configure pull secret or fix registry connectivity  
**Prevent**: Test `oc import-image` with `--confirm` before referencing in deployments

---

**Next**: [Module 03: Authentication & Authorization](03-authentication-and-authorization.md)

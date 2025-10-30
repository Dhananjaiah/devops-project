# OpenShift CLI (oc) Cheatsheet

## Authentication & Context

```bash
# Login to cluster
oc login ${CLUSTER_API} -u ${USER} -p ${PASSWORD}

# Who am I?
oc whoami
oc whoami --show-server
oc whoami --show-console
oc whoami -t  # Show token

# Switch project
oc project ${NS}
oc projects  # List all projects

# Logout
oc logout
```

## Project/Namespace Management

```bash
# Create project
oc new-project ${NS}

# Delete project
oc delete project ${NS}

# Get project details
oc get project ${NS}
oc describe project ${NS}

# Label project
oc label namespace ${NS} environment=prod
```

## Resource Management

```bash
# Get resources
oc get pods
oc get all  # Pods, Services, Deployments, ReplicaSets, etc.
oc get pods -A  # All namespaces
oc get pods -o wide  # More details
oc get pods -o yaml  # YAML output
oc get pods -o json | jq '.items[0].metadata.name'  # JSON + jq

# Describe resource (detailed info + events)
oc describe pod ${POD_NAME}
oc describe node ${NODE_NAME}

# Show labels
oc get pods --show-labels
oc get pods -l app=nginx  # Filter by label

# Apply/Create/Delete
oc apply -f manifest.yaml  # Declarative (idempotent)
oc create -f manifest.yaml  # Imperative (fails if exists)
oc delete -f manifest.yaml
oc delete pod ${POD_NAME}  # Delete specific resource

# Dry-run
oc apply -f manifest.yaml --dry-run=client  # Client-side validation
oc apply -f manifest.yaml --dry-run=server  # Server-side validation

# Diff before apply
oc diff -f manifest.yaml
```

## Deployments & Pods

```bash
# Create deployment
oc create deployment nginx --image=nginx:1.25 --replicas=3

# Scale deployment
oc scale deployment nginx --replicas=5

# Set image
oc set image deployment/nginx nginx=nginx:1.26

# Rollout management
oc rollout status deployment/nginx
oc rollout history deployment/nginx
oc rollout undo deployment/nginx  # Rollback
oc rollout restart deployment/nginx  # Restart pods

# Autoscaling
oc autoscale deployment nginx --min=2 --max=10 --cpu-percent=80

# Pod operations
oc run test-pod --image=nginx --rm -it --restart=Never -- /bin/bash
oc exec ${POD_NAME} -- ls /app
oc exec -it ${POD_NAME} -- /bin/sh
oc logs ${POD_NAME}
oc logs ${POD_NAME} --previous  # Previous terminated container
oc logs -f ${POD_NAME}  # Follow logs
oc logs ${POD_NAME} -c ${CONTAINER_NAME}  # Multi-container pod

# Port forward
oc port-forward ${POD_NAME} 8080:80  # Local 8080 -> Pod 80

# Copy files
oc cp ${POD_NAME}:/app/file.txt ./file.txt
oc cp ./file.txt ${POD_NAME}:/app/file.txt
```

## Services & Routes

```bash
# Expose service
oc expose deployment nginx --port=80 --target-port=8080

# Create Route (HTTP)
oc expose service nginx

# Create Route (HTTPS edge termination)
oc create route edge nginx-tls --service=nginx --insecure-policy=Redirect

# Create Route (HTTPS passthrough)
oc create route passthrough nginx-passthrough --service=nginx --port=8443

# Get Route URL
oc get route nginx -o jsonpath='{.spec.host}'

# Test service
oc run test --image=busybox --rm -it --restart=Never -- wget -qO- http://nginx
```

## ConfigMaps & Secrets

```bash
# Create ConfigMap
oc create configmap app-config --from-literal=KEY=value
oc create configmap app-config --from-file=config.txt

# Create Secret
oc create secret generic db-creds --from-literal=user=admin --from-literal=pass=secret
oc create secret docker-registry my-registry \
  --docker-server=${REGISTRY} \
  --docker-username=${USER} \
  --docker-password=${PASS}

# Mount ConfigMap as env vars
oc set env deployment/nginx --from=configmap/app-config

# Mount Secret as volume
oc set volume deployment/nginx \
  --add \
  --type=secret \
  --secret-name=db-creds \
  --mount-path=/etc/secrets

# View secret (base64 decoded)
oc get secret db-creds -o jsonpath='{.data.pass}' | base64 -d
```

## Labels & Annotations

```bash
# Add label
oc label pod ${POD_NAME} env=prod

# Remove label
oc label pod ${POD_NAME} env-

# Update label
oc label pod ${POD_NAME} env=staging --overwrite

# Add annotation
oc annotate deployment nginx description="Main web server"

# Filter by label
oc get pods -l env=prod
oc get pods -l 'env in (prod,staging)'
oc get pods -l env!=dev
```

## RBAC & Permissions

```bash
# Check permissions
oc auth can-i create pods
oc auth can-i get pods -n ${NS}
oc auth can-i '*' '*'  # All permissions
oc auth can-i create pods --as=${USER}  # Impersonate user

# Grant permissions
oc adm policy add-role-to-user admin ${USER} -n ${NS}
oc adm policy add-cluster-role-to-user cluster-admin ${USER}

# Remove permissions
oc adm policy remove-role-from-user admin ${USER} -n ${NS}

# List role bindings
oc get rolebindings -n ${NS}
oc get clusterrolebindings | grep ${USER}

# Describe roles
oc describe clusterrole admin
oc describe role developer -n ${NS}
```

## Resource Usage & Debugging

```bash
# Resource usage
oc adm top nodes
oc adm top pods -n ${NS}

# Node management
oc get nodes
oc describe node ${NODE_NAME}
oc adm cordon ${NODE_NAME}  # Mark unschedulable
oc adm drain ${NODE_NAME} --ignore-daemonsets --delete-emptydir-data
oc adm uncordon ${NODE_NAME}  # Make schedulable

# Events
oc get events -n ${NS}
oc get events -n ${NS} --sort-by='.lastTimestamp'
oc get events -n ${NS} --field-selector involvedObject.name=${POD_NAME}

# Debug pod
oc debug pod/${POD_NAME}
oc debug node/${NODE_NAME}

# Check cluster health
oc get clusterversion
oc get clusteroperators
oc status
```

## Image Management

```bash
# List ImageStreams
oc get imagestreams
oc describe imagestream ${NAME}

# Import image
oc import-image ${NAME}:${TAG} --from=${REGISTRY}/${IMAGE}:${TAG} --confirm

# Tag image
oc tag ${SOURCE_IMAGE} ${DEST_IMAGE}
```

## Kustomize Integration

```bash
# Preview Kustomize output
oc kustomize ./overlays/dev

# Apply Kustomize overlay
oc apply -k ./overlays/prod

# Diff Kustomize changes
oc kustomize ./overlays/prod | oc diff -f -
```

## Cluster Administration

```bash
# View cluster version
oc get clusterversion
oc describe clusterversion version

# Check for updates
oc adm upgrade

# Upgrade cluster
oc adm upgrade --to=${VERSION}

# Backup namespace resources
oc get all,cm,secret,pvc -n ${NS} -o yaml > backup.yaml

# Must-complete before shutdown
oc adm drain ${NODE} --ignore-daemonsets --delete-emptydir-data
```

## Quick Generators

```bash
# Generate YAML without applying
oc create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml
oc expose service nginx --dry-run=client -o yaml > route.yaml
oc create secret generic db --from-literal=pass=secret --dry-run=client -o yaml > secret.yaml
```

## Useful Flags

| Flag | Purpose |
|------|---------|
| `-n ${NS}` | Specify namespace |
| `-A` | All namespaces |
| `-o yaml` | YAML output |
| `-o json` | JSON output |
| `-o wide` | Extra columns |
| `-o name` | Resource name only |
| `-o jsonpath='{.spec.host}'` | Extract specific field |
| `--show-labels` | Display labels |
| `-l app=nginx` | Filter by label |
| `--sort-by=.metadata.creationTimestamp` | Sort results |
| `--field-selector` | Filter by field |
| `-w` | Watch for changes |
| `--dry-run=client` | Preview without server |
| `--dry-run=server` | Server validation |

## Tips & Tricks

```bash
# Set default namespace
oc config set-context --current --namespace=${NS}

# Switch context
oc config use-context ${CONTEXT}

# View kubeconfig
oc config view

# Create alias
alias k='oc'

# Command history search
Ctrl+R

# Watch resources
watch oc get pods

# Multi-container pod logs
oc logs ${POD} -c ${CONTAINER}

# Copy all resources from one NS to another
oc get all -n source -o yaml | sed 's/namespace: source/namespace: dest/' | oc apply -f -
```

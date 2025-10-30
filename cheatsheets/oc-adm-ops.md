# OpenShift Admin Operations (oc adm) Cheatsheet

## Cluster Upgrades

```bash
# View current version
oc get clusterversion
oc describe clusterversion version

# Check available updates
oc adm upgrade
oc adm upgrade --to-latest=true

# Change update channel
oc adm upgrade channel stable-4.14

# Upgrade to specific version
oc adm upgrade --to=4.14.15

# Monitor upgrade
oc get clusterversion -w
oc get clusteroperators
oc get nodes

# View upgrade history
oc describe clusterversion version | grep -A20 History
```

## Node Management

```bash
# List nodes
oc get nodes
oc get nodes -o wide

# Describe node
oc describe node ${NODE_NAME}

# Cordon node (mark unschedulable)
oc adm cordon ${NODE_NAME}

# Drain node (evict pods safely)
oc adm drain ${NODE_NAME} \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --force \
  --grace-period=300

# Uncordon node (restore scheduling)
oc adm uncordon ${NODE_NAME}

# Taint node
oc adm taint nodes ${NODE_NAME} key=value:NoSchedule
oc adm taint nodes ${NODE_NAME} key-  # Remove taint

# Label node
oc label node ${NODE_NAME} env=prod
```

## RBAC Management

```bash
# Grant role to user in namespace
oc adm policy add-role-to-user admin ${USER} -n ${NS}
oc adm policy add-role-to-user edit ${USER} -n ${NS}
oc adm policy add-role-to-user view ${USER} -n ${NS}

# Grant cluster role to user
oc adm policy add-cluster-role-to-user cluster-admin ${USER}
oc adm policy add-cluster-role-to-user cluster-reader ${USER}

# Grant SCC to ServiceAccount
oc adm policy add-scc-to-user anyuid -z ${SA} -n ${NS}
oc adm policy add-scc-to-user privileged -z ${SA} -n ${NS}
oc adm policy add-scc-to-user nonroot -z ${SA} -n ${NS}

# Grant role to group
oc adm policy add-role-to-group edit developers -n ${NS}
oc adm policy add-cluster-role-to-group cluster-admin admins

# Remove role from user
oc adm policy remove-role-from-user admin ${USER} -n ${NS}
oc adm policy remove-cluster-role-from-user cluster-admin ${USER}

# Remove SCC from ServiceAccount
oc adm policy remove-scc-from-user anyuid -z ${SA} -n ${NS}

# View policy (who can do what)
oc adm policy who-can create pods -n ${NS}
oc adm policy who-can delete nodes
```

## User & Group Management

```bash
# Create group
oc adm groups new developers
oc adm groups new admins

# Add users to group
oc adm groups add-users developers user1 user2 user3

# Remove users from group
oc adm groups remove-users developers user1

# View groups
oc get groups
oc describe group developers

# View identities
oc get identities
oc get users
```

## Resource Management

```bash
# Top nodes (resource usage)
oc adm top nodes
oc adm top nodes --sort-by=cpu
oc adm top nodes --sort-by=memory

# Top pods (resource usage)
oc adm top pods -n ${NS}
oc adm top pods -A
oc adm top pods -n ${NS} --sort-by=cpu
oc adm top pods -n ${NS} --containers  # Per-container stats

# Prune old resources
oc adm prune images --confirm  # Remove unused images from registry
oc adm prune builds --confirm  # Remove old builds
oc adm prune deployments --confirm  # Remove old replication controllers
```

## Project Templates

```bash
# Generate default project request template
oc adm create-bootstrap-project-template -o yaml > project-template.yaml

# Create custom template in openshift-config
oc create -f project-template.yaml -n openshift-config

# Configure cluster to use template
oc patch project.config.openshift.io/cluster --type=merge \
  -p '{"spec":{"projectRequestTemplate":{"name":"project-request"}}}'

# Verify template
oc get template project-request -n openshift-config
```

## Certificates

```bash
# Approve certificate signing request
oc get csr
oc adm certificate approve ${CSR_NAME}

# Deny certificate
oc adm certificate deny ${CSR_NAME}
```

## Registry Management

```bash
# Configure image registry
oc patch configs.imageregistry.operator.openshift.io/cluster \
  --type=merge \
  -p '{"spec":{"storage":{"pvc":{"claim":""}}}}'

# Expose registry route
oc patch configs.imageregistry.operator.openshift.io/cluster \
  --type=merge \
  -p '{"spec":{"defaultRoute":true}}'

# Prune old images
oc adm prune images --confirm
oc adm prune images --keep-tag-revisions=3 --keep-younger-than=60m --confirm
```

## Diagnostics & Verification

```bash
# Verify cluster health
oc adm verify cluster

# Node diagnostics
oc adm node-logs ${NODE_NAME}
oc adm node-logs ${NODE_NAME} -u kubelet
oc adm node-logs ${NODE_NAME} -u crio

# Must-gather (collect cluster diagnostics)
oc adm must-gather
oc adm must-gather --image=${IMAGE}  # Custom image
```

## Migration

```bash
# Migrate deprecated APIs
oc adm migrate stored-versions
```

## Cluster Configuration

```bash
# Configure OAuth
oc edit oauth cluster

# Configure ingress
oc edit ingresses.config.openshift.io cluster

# Configure scheduler
oc edit schedulers.config.openshift.io cluster

# Configure API server
oc edit apiservers.config.openshift.io cluster
```

## Monitoring & Alerts

```bash
# View cluster operators
oc get clusteroperators
oc get co  # Short form

# Describe degraded operator
oc describe co ${OPERATOR_NAME}

# Check critical pods
oc get pods -n openshift-etcd
oc get pods -n openshift-kube-apiserver
oc get pods -n openshift-authentication
oc get pods -n openshift-ingress
```

## Emergency & Recovery

```bash
# Force delete stuck namespace
oc patch namespace ${NS} -p '{"metadata":{"finalizers":[]}}' --type=merge
oc delete namespace ${NS} --force --grace-period=0

# Force delete stuck pod
oc delete pod ${POD_NAME} --force --grace-period=0 -n ${NS}

# Restart control plane pods (DANGER)
oc delete pod -n openshift-kube-apiserver -l app=openshift-kube-apiserver
oc delete pod -n openshift-authentication -l app=oauth-openshift
```

## Quota & Limits

```bash
# View namespace quotas
oc get resourcequota -A
oc describe resourcequota ${NAME} -n ${NS}

# View limit ranges
oc get limitrange -A
oc describe limitrange ${NAME} -n ${NS}
```

## Network

```bash
# View cluster network config
oc get network.config.openshift.io cluster -o yaml

# View network operator
oc get clusteroperator network

# View SDN pods
oc get pods -n openshift-sdn  # Or openshift-ovn-kubernetes

# Network diagnostics
oc debug node/${NODE_NAME}
# Inside debug pod:
ip addr
ip route
iptables -L -n -v
```

## Storage

```bash
# View storage classes
oc get storageclass
oc describe storageclass ${NAME}

# Set default storage class
oc patch storageclass ${NAME} \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# View PVs
oc get pv
oc describe pv ${PV_NAME}

# View PVCs across namespaces
oc get pvc -A
```

## Backup & Restore

```bash
# Backup namespace resources
oc get all,cm,secret,sa,role,rolebinding,pvc -n ${NS} -o yaml > backup-${NS}.yaml

# Backup CRDs
oc get crd -o yaml > backup-crds.yaml

# Backup cluster RBAC
oc get clusterrole,clusterrolebinding -o yaml > backup-rbac.yaml

# Restore
oc apply -f backup-${NS}.yaml -n ${NS}
```

## Troubleshooting Commands

```bash
# View all resources in namespace
oc get all -n ${NS}

# View events
oc get events -n ${NS} --sort-by='.lastTimestamp'

# Describe all pods
oc describe pods -n ${NS}

# Logs from all pods with label
oc logs -l app=myapp -n ${NS} --tail=50

# Check pod scheduling issues
oc describe pod ${POD_NAME} -n ${NS} | grep -A10 Events

# Debug pod
oc debug pod/${POD_NAME} -n ${NS}

# Debug node
oc debug node/${NODE_NAME}
```

## Useful Combinations

```bash
# Find pods on specific node
oc get pods -A -o wide --field-selector spec.nodeName=${NODE_NAME}

# Find pending pods
oc get pods -A --field-selector status.phase=Pending

# Find pods with restarts
oc get pods -A --field-selector status.phase=Running | awk '$5>0'

# Delete all pods in namespace
oc delete pods --all -n ${NS}

# Delete all resources in namespace
oc delete all --all -n ${NS}

# Export resource without cluster-specific fields
oc get deployment ${NAME} -o yaml | \
  yq 'del(.status, .metadata.uid, .metadata.resourceVersion, .metadata.generation)' \
  > clean-deployment.yaml
```

## Advanced Operations

```bash
# Impersonate user
oc get pods --as=${USER} -n ${NS}

# Impersonate group
oc get pods --as-group=system:authenticated -n ${NS}

# View audit logs (if enabled)
oc adm node-logs ${NODE_NAME} --path=kube-apiserver/audit.log

# Cluster capacity analysis
oc adm top nodes
oc get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory
```

## Tips

- Use `--dry-run=server` to test changes before applying
- Always backup before destructive operations
- Use `oc adm must-gather` when opening support tickets
- Test RBAC changes with `--as` flag before applying
- Monitor cluster health with `oc get co` regularly

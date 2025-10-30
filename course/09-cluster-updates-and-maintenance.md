# Module 09: Cluster Updates & Maintenance

## Goals

- Perform cluster upgrades using `oc adm upgrade`
- Understand update channels and payloads
- Safely drain and cordon nodes for maintenance
- Backup critical cluster objects (etcd, resources)
- Configure and use internal image registry
- Mirror images for disconnected environments
- Handle update blockers and rollbacks

## Key Terms

- **Channel**: Update stream (stable, fast, candidate, eus)
- **Payload**: Cluster update image containing all components
- **ClusterVersion**: Resource managing cluster update state
- **Drain**: Safely evict pods from node before maintenance
- **Cordon**: Mark node as unschedulable (no new pods)
- **Etcd**: Key-value store holding all cluster state
- **Image Registry**: Internal registry for built images (registry.redhat.io mirror)
- **Mirroring**: Copy images to local registry for air-gapped clusters

## Commands First

```bash
# View current cluster version
oc get clusterversion
oc describe clusterversion version

# Check available updates
oc adm upgrade
oc adm upgrade --to-latest=true  # Show latest in current channel

# Change update channel
oc adm upgrade channel ${CHANNEL}

# Upgrade to specific version
oc adm upgrade --to=4.14.15

# Monitor upgrade progress
oc get clusterversion -w
oc get clusteroperators  # Check all operators healthy
oc get nodes  # Verify nodes upgraded

# View update history
oc describe clusterversion version | grep -A20 History

# Cordon node (mark unschedulable)
oc adm cordon <node-name>
oc get nodes  # Shows SchedulingDisabled

# Drain node (evict pods safely)
oc adm drain <node-name> \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --force \
  --grace-period=300

# Uncordon node (restore scheduling)
oc adm uncordon <node-name>

# Backup etcd (requires cluster-admin)
oc get etcdbackup -n openshift-etcd
# DANGER: Manual etcd backup for critical scenarios only
# Managed OpenShift (ROSA, ARO) handles backups automatically

# Backup cluster resources (declarative)
oc get all,cm,secret,sa,role,rolebinding -n ${NS} -o yaml > backup-${NS}.yaml
oc get crd -o yaml > backup-crds.yaml
oc get clusterrole,clusterrolebinding -o yaml > backup-rbac.yaml

# Restore from backup
oc apply -f backup-${NS}.yaml -n ${NS}

# Configure image registry storage (if not auto-provisioned)
oc patch configs.imageregistry.operator.openshift.io/cluster \
  --type=merge \
  -p '{"spec":{"storage":{"pvc":{"claim":""}}}}'

# Expose internal registry
oc patch configs.imageregistry.operator.openshift.io/cluster \
  --type=merge \
  -p '{"spec":{"defaultRoute":true}}'

REGISTRY_HOST=$(oc get route default-route -n openshift-image-registry -o jsonpath='{.spec.host}')

# Login to internal registry
oc whoami -t | podman login -u $(oc whoami) --password-stdin ${REGISTRY_HOST}

# Push image to internal registry
podman tag nginx:latest ${REGISTRY_HOST}/${NS}/nginx:latest
podman push ${REGISTRY_HOST}/${NS}/nginx:latest

# Mirror images for disconnected install (requires oc-mirror)
oc mirror --config=imageset-config.yaml file://mirror
oc mirror --from=file://mirror docker://${LOCAL_REGISTRY}

# Prune old images from registry
oc adm prune images --confirm

# Verify cluster health before/after maintenance
oc get clusteroperators
oc get nodes
oc get clusterversion
oc get co | grep -v 'True.*False.*False'  # Any not available/progressing/degraded?
```

**Why/Notes**: Cluster upgrades are managed by ClusterVersion Operator (automated, low-risk). Always drain nodes before maintenance to avoid pod disruption. Backup critical resources before upgrades. Internal registry stores S2I images; external registry (Quay) better for production. Mirroring enables air-gapped installs.

## Verify

```bash
# Check cluster health
oc get clusteroperators
oc get clusterversion

# Verify nodes healthy
oc get nodes
oc adm top nodes

# Check upgrade blockers
oc adm upgrade  # Lists any upgrade blockers

# Verify registry accessible
oc get configs.imageregistry.operator.openshift.io cluster -o yaml
oc get route -n openshift-image-registry

# Test image push/pull
podman pull ${REGISTRY_HOST}/${NS}/nginx:latest
```

Expected: ClusterOperators all Available=True, upgrade proceeds without errors, nodes drained/uncordoned successfully, registry stores images.

## Mini-Lab (5-10 min)

**Scenario**: Drain node for maintenance, backup namespace resources, configure internal registry.

1. **Check cluster status**:

```bash
oc get clusterversion
oc get clusteroperators
oc get nodes

# View update channel and available updates
oc adm upgrade
oc describe clusterversion version | grep 'Desired Version'
```

2. **Cordon and drain a node**:

```bash
# Pick a worker node (not master)
NODE_NAME=$(oc get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[0].metadata.name}')

# Cordon node (mark unschedulable)
oc adm cordon ${NODE_NAME}
oc get node ${NODE_NAME} | grep SchedulingDisabled

# Drain node (move pods elsewhere)
oc adm drain ${NODE_NAME} \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --grace-period=60

# Verify pods moved off node
oc get pods -A -o wide | grep ${NODE_NAME}
# Should see no pods (except DaemonSets)

# Simulate maintenance (wait)
sleep 30

# Uncordon node
oc adm uncordon ${NODE_NAME}
oc get nodes | grep ${NODE_NAME}
# Should show Ready, not SchedulingDisabled
```

3. **Backup namespace resources**:

```bash
mkdir -p ~/backups
oc new-project demo-backup

# Create some resources
oc create deployment nginx --image=nginx -n demo-backup
oc expose deployment nginx --port=80 -n demo-backup
oc create secret generic db-creds --from-literal=pass=abc123 -n demo-backup

# Backup all namespace resources
oc get all,cm,secret,sa,pvc -n demo-backup -o yaml > ~/backups/demo-backup-$(date +%Y%m%d).yaml

# Simulate disaster (delete project)
oc delete project demo-backup

# Wait for deletion
sleep 30

# Restore from backup
oc new-project demo-backup
oc apply -f ~/backups/demo-backup-*.yaml -n demo-backup

# Verify resources restored
oc get all,secret -n demo-backup
```

4. **Configure internal registry**:

```bash
# Enable default route (if not already exposed)
oc patch configs.imageregistry.operator.openshift.io/cluster \
  --type=merge \
  -p '{"spec":{"defaultRoute":true}}'

# Wait for route to be created
oc get route default-route -n openshift-image-registry -w

REGISTRY_HOST=$(oc get route default-route -n openshift-image-registry -o jsonpath='{.spec.host}')

# Login to registry
TOKEN=$(oc whoami -t)
echo $TOKEN | podman login -u $(oc whoami) --password-stdin ${REGISTRY_HOST}

# Push test image
oc new-project demo-registry
podman pull busybox:latest
podman tag busybox:latest ${REGISTRY_HOST}/demo-registry/busybox:v1
podman push ${REGISTRY_HOST}/demo-registry/busybox:v1

# Verify image in registry
oc get imagestreams -n demo-registry
oc get imagestreamtags -n demo-registry
```

5. **View update history and check for blockers**:

```bash
oc describe clusterversion version | grep -A10 History

# Check for upgrade blockers
oc adm upgrade --to-latest=true
# If blockers exist, you'll see warnings

# View cluster operator status
oc get co -o custom-columns=NAME:.metadata.name,AVAILABLE:.status.conditions[?(@.type==\"Available\")].status,PROGRESSING:.status.conditions[?(@.type==\"Progressing\")].status,DEGRADED:.status.conditions[?(@.type==\"Degraded\")].status
```

## Quiz (5 Questions)

1. **Q**: What's the difference between cordon and drain?  
   **A**: Cordon marks node unschedulable; drain evicts existing pods + cordons.

2. **Q**: How do you check available cluster updates?  
   **A**: `oc adm upgrade` shows available updates in current channel.

3. **Q**: What does `--ignore-daemonsets` do when draining?  
   **A**: Ignores DaemonSet pods (can't be evicted; tied to node lifecycle).

4. **Q**: How do you expose the internal image registry?  
   **A**: `oc patch configs.imageregistry.operator.openshift.io/cluster --type=merge -p '{"spec":{"defaultRoute":true}}'`

5. **Q**: What resource manages cluster version and updates?  
   **A**: ClusterVersion (singular resource named "version").

## Common Mistakes

- **Upgrading without checking blockers**: `oc adm upgrade` warns about issues; resolve before upgrading.
- **Draining master nodes carelessly**: Draining multiple masters simultaneously breaks etcd quorum.
- **Not backing up before upgrades**: DANGER: Always backup critical resources and etcd.
- **Forcing drain without grace period**: Causes abrupt pod termination; use appropriate grace period.
- **Changing channels during upgrade**: Wait for current upgrade to finish before switching channels.

## Troubleshooting

See [Triage Matrix: Upgrade & Maintenance Issues](../troubleshooting/triage-matrix.md#cluster-maintenance)

**Symptom**: Cluster upgrade stuck "Progressing"  
**Triage**: `oc get co` shows degraded operator; `oc describe co <name>` shows error  
**Fix**: Resolve operator issue (often node, registry, or authentication operator)  
**Prevent**: Ensure all operators healthy before initiating upgrade

**Symptom**: Node drain hangs indefinitely  
**Triage**: `oc get pods -A | grep <node>` shows stuck pods  
**Fix**: Identify pod blocking drain (PDB, local storage); delete with `--force` if safe  
**Prevent**: Use PodDisruptionBudgets wisely; avoid local storage without backups

**Symptom**: Internal registry not accessible  
**Triage**: `oc get co image-registry` shows degraded; route missing  
**Fix**: Configure storage backend (PVC, S3, Azure); enable default route  
**Prevent**: Verify registry storage configured during cluster install

---

**Next**: [Module 10: Comprehensive Review](10-comprehensive-review.md)

# FoodCart SRE Runbook

## On-Call Playbooks

### P1: Service Down (All Pods Failing)

**Symptom**: Gateway route returns 503, no pods running

**Triage**:
```bash
oc get pods -n ${NS}  # Check pod status
oc describe pod <pod-name> -n ${NS}  # Get failure reason
oc get events -n ${NS} --sort-by='.lastTimestamp' | tail -20
```

**Root Causes & Fixes**:

1. **Image Pull Error**:
   - `oc set image deployment/<name> *=<correct-image>`
   
2. **Quota Exceeded**:
   - `oc describe quota -n ${NS}`
   - Delete unused resources or increase quota

3. **SCC Violation**:
   - Check: `oc describe pod <name> | grep -i scc`
   - Fix: Create SA with appropriate SCC

**Verify**: `oc wait --for=condition=ready pod -l app=foodcart -n ${NS} --timeout=120s`

---

### P2: Database Connection Failures

**Symptom**: Orders service logs show "connection refused" to DB

**Triage**:
```bash
oc logs deployment/orders -n ${NS} | grep -i database
oc get pods -l service=db -n ${NS}
oc exec deployment/orders -n ${NS} -- nc -zv db 5432
```

**Root Causes & Fixes**:

1. **DB Pod Not Running**:
   - `oc get statefulset db -n ${NS}`
   - Check PVC bound: `oc get pvc -n ${NS}`
   - Scale up if needed: `oc scale sts/db --replicas=1 -n ${NS}`

2. **NetworkPolicy Blocking**:
   - Check: `oc get networkpolicy -n ${NS}`
   - Verify allow-orders-to-db policy exists

3. **Wrong Credentials**:
   - Verify secret: `oc get secret db-credentials -n ${NS} -o yaml`
   - Recreate if corrupted

**Verify**: `oc exec deployment/orders -n ${NS} -- psql -h db -U foodcart -c '\l'`

---

### P3: High Latency / Slow Response

**Symptom**: Route responds slowly (>2s response time)

**Triage**:
```bash
oc adm top pods -n ${NS}  # Check resource usage
oc get hpa -n ${NS}  # HPA status
oc describe deployment/<name> -n ${NS} | grep -A5 Conditions
```

**Root Causes & Fixes**:

1. **Resource Exhaustion**:
   - CPU/memory at limits
   - Fix: Increase HPA maxReplicas or resource limits

2. **Pod Restarting**:
   - Check: `oc get pods -n ${NS}`
   - Review logs: `oc logs --previous <pod> -n ${NS}`
   - Fix probe failures or OOMKilled issues

3. **Network Congestion**:
   - Check service endpoints: `oc get endpoints -n ${NS}`
   - Verify pod distribution across nodes

**Verify**: `curl -w "@curl-format.txt" -o /dev/null -s https://<route>`

---

### P4: Route 503 (No Healthy Backends)

**Symptom**: Route accessible but returns 503 Service Unavailable

**Triage**:
```bash
oc get route gateway -n ${NS}
oc get endpoints gateway -n ${NS}  # Should show pod IPs
oc get pods -l service=gateway -n ${NS}  # Check pod status
```

**Root Causes & Fixes**:

1. **No Ready Pods**:
   - Check readiness probe failing
   - Review logs: `oc logs deployment/gateway -n ${NS}`

2. **Service Selector Mismatch**:
   - Compare labels: `oc get pods --show-labels -n ${NS}`
   - Fix service selector to match pod labels

3. **NetworkPolicy Blocking Router**:
   - Verify: `oc get networkpolicy allow-ingress-to-gateway -n ${NS}`
   - Ensure ingress from `network.openshift.io/policy-group: ingress`

**Verify**: `oc get endpoints gateway -n ${NS}` shows pod IPs

---

### P5: PVC Stuck in Pending

**Symptom**: Database StatefulSet pod pending, PVC not bound

**Triage**:
```bash
oc get pvc -n ${NS}
oc describe pvc <pvc-name> -n ${NS}
oc get storageclasses
```

**Root Causes & Fixes**:

1. **No Available PVs**:
   - Check: `oc get pv | grep Available`
   - For dynamic provisioning, verify StorageClass exists

2. **StorageClass Not Default**:
   - Set default: `oc patch storageclass <name> -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`

3. **Quota Exceeded**:
   - Check: `oc describe quota -n ${NS} | grep persistentvolumeclaims`

**Verify**: `oc get pvc -n ${NS}` shows "Bound" status

---

## Maintenance Procedures

### Scheduled Downtime (Deploy New Version)

```bash
# 1. Backup current state
oc get all,route,networkpolicy,pvc -n ${NS} -o yaml > backup-$(date +%Y%m%d).yaml

# 2. Scale down replicas (reduces resource usage)
oc scale deployment --all --replicas=0 -n ${NS}

# 3. Apply new manifests
oc apply -k overlays/prod

# 4. Wait for rollout
oc rollout status deployment/gateway -n ${NS}

# 5. Run smoke tests
./scripts/smoke-test.sh ${NS}

# 6. Verify via route
curl -I https://<route>
```

### Rolling Update (Zero Downtime)

```bash
# Update image
oc set image deployment/orders orders=quay.io/myorg/orders:v2 -n ${NS}

# Monitor rollout
oc rollout status deployment/orders -n ${NS}

# Rollback if issues
oc rollout undo deployment/orders -n ${NS}
```

### Database Backup

```bash
# Manual backup
DB_POD=$(oc get pod -l service=db -n ${NS} -o jsonpath='{.items[0].metadata.name}')
oc exec ${DB_POD} -n ${NS} -- pg_dump -U foodcart foodcart > backup-$(date +%Y%m%d).sql

# Restore
cat backup-20240101.sql | oc exec -i ${DB_POD} -n ${NS} -- psql -U foodcart foodcart
```

---

## Disaster Recovery

### Full Namespace Loss

```bash
# 1. Recreate namespace
oc new-project ${NS}

# 2. Restore from backup
oc apply -f backup-20240101.yaml

# 3. Verify resources
oc get all -n ${NS}

# 4. Restore database
# (see Database Backup section)
```

### Cluster Upgrade Issues

```bash
# If pods fail after upgrade, check operator versions
oc get clusteroperators
oc describe co <name>

# Force operator reconciliation
oc delete pod -l app=<operator> -n openshift-<namespace>
```

---

## Monitoring & Alerts

### Key Metrics

- **Pod Restart Count**: `oc get pods -n ${NS} --sort-by='.status.containerStatuses[0].restartCount'`
- **Resource Usage**: `oc adm top pods -n ${NS}`
- **HPA Status**: `oc get hpa -n ${NS} -o wide`
- **PVC Usage**: `oc exec <pod> -n ${NS} -- df -h /var/lib/postgresql/data`

### Alert Thresholds

- Pod restart count > 5 in 10 min → P2
- CPU > 90% for 5 min → P3
- Memory > 90% for 5 min → P3
- All replicas down → P1
- Route 5xx rate > 10% → P2

---

## Contacts

- **On-Call SRE**: oncall@example.com
- **Platform Team**: platform@example.com
- **Database Team**: dba@example.com
- **Escalation**: manager@example.com

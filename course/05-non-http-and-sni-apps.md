# Module 05: Non-HTTP & SNI Applications

## Goals

- Expose TCP/UDP services with ClusterIP, NodePort, LoadBalancer
- Configure passthrough Routes for SNI (Server Name Indication)
- Understand when to use each Service type
- Deploy database and messaging services
- Brief introduction to Multus for additional network interfaces
- Troubleshoot service connectivity issues

## Key Terms

- **ClusterIP**: Internal service accessible only within cluster (default)
- **NodePort**: Exposes service on static port on each node (30000-32767)
- **LoadBalancer**: Cloud provider LB (ELB/NLB on AWS, ALB on Azure)
- **SNI (Server Name Indication)**: TLS extension allowing multiple certs on one IP
- **Passthrough Route**: OpenShift Route forwarding TLS traffic without termination
- **Multus**: CNI plugin enabling multiple network interfaces per pod
- **Headless Service**: ClusterIP=None; returns pod IPs for stateful apps

## Commands First

```bash
# Create ClusterIP service (default, internal only)
oc expose deployment myapp --port=8080 --target-port=8080
oc get svc myapp  # ClusterIP assigned

# Create NodePort service (external access via node IPs)
oc expose deployment myapp --type=NodePort --port=8080 --name=myapp-nodeport
oc get svc myapp-nodeport  # Note NodePort in 30000-32767 range

# Create LoadBalancer service (cloud provider LB)
oc expose deployment myapp --type=LoadBalancer --port=8080 --name=myapp-lb
oc get svc myapp-lb  # EXTERNAL-IP shows cloud LB address

# Access NodePort service
NODE_IP=$(oc get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(oc get svc myapp-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
curl http://${NODE_IP}:${NODE_PORT}

# Passthrough Route for SNI (TLS to pod, e.g., PostgreSQL with SSL)
oc create route passthrough postgres-tls \
  --service=postgres \
  --hostname=db.${APPS_DOMAIN} \
  --port=5432

# Headless service for StatefulSet (returns pod IPs)
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
EOF

# Query headless service (returns pod IPs)
oc run dns-test --image=busybox --rm -it --restart=Never -- nslookup postgres-headless

# Configure external service (ClusterIP pointing to external DB)
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ClusterIP
  ports:
  - port: 5432
---
apiVersion: v1
kind: Endpoints
metadata:
  name: external-db
subsets:
- addresses:
  - ip: 10.0.1.50  # External database IP
  ports:
  - port: 5432
EOF

# Test service connectivity
oc run netshoot --image=nicolaka/netshoot --rm -it --restart=Never -- bash
# Inside pod: curl, telnet, nc to test ports

# Multus: Add NetworkAttachmentDefinition (requires Multus CNI)
cat <<EOF | oc apply -f -
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: macvlan-conf
spec:
  config: '{
    "cniVersion": "0.3.1",
    "type": "macvlan",
    "master": "eth1",
    "mode": "bridge",
    "ipam": {
      "type": "host-local",
      "subnet": "192.168.1.0/24"
    }
  }'
EOF

# Pod with additional network interface
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: multus-pod
  annotations:
    k8s.v1.cni.cncf.io/networks: macvlan-conf
spec:
  containers:
  - name: app
    image: nginx
EOF
```

**Why/Notes**: ClusterIP is default for internal services. NodePort for dev/testing external access. LoadBalancer for production cloud deployments. Passthrough Routes enable SNI for multiple TLS services on one IP. Multus adds advanced networking (SR-IOV, macvlan) for NFV/telco workloads.

## Verify

```bash
# Check service types
oc get svc -n ${NS}
oc describe svc myapp-nodeport

# Test NodePort connectivity
curl http://${NODE_IP}:${NODE_PORT}

# Test LoadBalancer (wait for EXTERNAL-IP)
oc get svc myapp-lb -w  # Wait for IP assignment
LB_IP=$(oc get svc myapp-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://${LB_IP}:8080

# Verify passthrough Route
oc get route postgres-tls
openssl s_client -connect db.${APPS_DOMAIN}:443 -servername db.${APPS_DOMAIN}

# Check Multus network interfaces
oc exec multus-pod -- ip addr show
```

Expected: Services accessible via ClusterIP (internal), NodePort (node IP:port), LoadBalancer (cloud LB IP). Passthrough Route forwards TLS.

## Mini-Lab (5-10 min)

**Scenario**: Deploy Redis (TCP service) with ClusterIP and NodePort. Expose via passthrough Route with TLS.

1. **Deploy Redis**:

```bash
oc new-project demo-tcp
oc create deployment redis --image=redis:7-alpine
oc set env deployment/redis REDIS_PASSWORD=redis123
oc label deployment redis app=redis
```

2. **Expose with ClusterIP** (default):

```bash
oc expose deployment redis --port=6379
oc get svc redis

# Test internal access
oc run redis-cli --image=redis:7-alpine --rm -it --restart=Never -- \
  redis-cli -h redis -p 6379 PING
# Should return PONG
```

3. **Expose with NodePort**:

```bash
oc expose deployment redis --type=NodePort --port=6379 --name=redis-nodeport
oc get svc redis-nodeport

NODE_IP=$(oc get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(oc get svc redis-nodeport -o jsonpath='{.spec.ports[0].nodePort}')

# Test NodePort access (if node IP is reachable)
redis-cli -h ${NODE_IP} -p ${NODE_PORT} PING
```

4. **Configure Redis with TLS** (simulate):

```bash
# For demo, we'll use passthrough Route assuming Redis has TLS enabled
# Real Redis TLS requires cert/key config in redis.conf

oc create route passthrough redis-tls \
  --service=redis \
  --port=6379

oc get route redis-tls -o yaml
REDIS_ROUTE=$(oc get route redis-tls -o jsonpath='{.spec.host}')

# Test (would work if Redis TLS is configured)
# openssl s_client -connect ${REDIS_ROUTE}:443
```

5. **Deploy PostgreSQL with headless service**:

```bash
oc create deployment postgres --image=postgres:15-alpine
oc set env deployment/postgres POSTGRES_PASSWORD=pg123
oc label deployment postgres app=postgres

# Headless service
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
EOF

# Query DNS (returns pod IPs)
oc run dns-test --image=busybox --rm -it --restart=Never -- \
  nslookup postgres-headless.demo-tcp.svc.cluster.local
# Should return pod IPs instead of service IP
```

## Quiz (5 Questions)

1. **Q**: When should you use NodePort vs LoadBalancer?  
   **A**: NodePort for dev/testing; LoadBalancer for production with cloud provider.

2. **Q**: What does ClusterIP=None mean?  
   **A**: Headless service; DNS returns pod IPs instead of single service IP (for StatefulSets).

3. **Q**: How does passthrough Route handle TLS?  
   **A**: Forwards encrypted TLS traffic directly to pod without terminating at Router.

4. **Q**: What port range is used for NodePort services?  
   **A**: 30000-32767 (configurable via kube-apiserver flag).

5. **Q**: What is Multus used for?  
   **A**: Attach multiple network interfaces to pods (macvlan, SR-IOV, etc.).

## Common Mistakes

- **Using LoadBalancer in on-prem clusters**: Requires MetalLB or similar; cloud-only by default.
- **Forgetting NodePort range**: Specifying port outside 30000-32767 fails; use `--node-port` flag.
- **Passthrough Route without TLS in pod**: Pod must handle TLS; passthrough doesn't add encryption.
- **Headless service with Deployment**: Pods get random IPs; use StatefulSet for stable DNS names.
- **External Service without Endpoints**: Must manually create Endpoints object for external IPs.

## Troubleshooting

See [Triage Matrix: Service Connectivity Issues](../troubleshooting/triage-matrix.md#service-connectivity)

**Symptom**: NodePort service not accessible externally  
**Triage**: `oc get svc` shows NodePort; `telnet <node-ip> <node-port>` times out  
**Fix**: Check firewall rules, security groups, or NetworkPolicy blocking node ports  
**Prevent**: Verify network connectivity before exposing NodePort in production

**Symptom**: LoadBalancer EXTERNAL-IP stuck in Pending  
**Triage**: `oc describe svc` shows no LB provisioning events  
**Fix**: Verify cloud provider integration (AWS ELB controller, MetalLB, etc.)  
**Prevent**: Use NodePort or Routes if LoadBalancer not available

---

**Next**: [Module 06: Developer Self-Service](06-developer-self-service.md)

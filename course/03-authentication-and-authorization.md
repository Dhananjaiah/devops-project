# Module 03: Authentication & Authorization

## Goals

- Configure Identity Providers (HTPasswd, LDAP, GitHub OAuth)
- Create and manage users and groups
- Implement RBAC with Roles, ClusterRoles, and Bindings
- Use `oc auth can-i` to test permissions
- Grant cluster-admin vs project-admin access safely
- Audit user permissions and troubleshoot access denials

## Key Terms

- **Identity Provider (IdP)**: External auth system (HTPasswd, LDAP, OAuth)
- **User**: Authenticated identity in OpenShift
- **Group**: Collection of users for bulk RBAC assignment
- **Role**: Namespaced permissions (e.g., edit pods in project X)
- **ClusterRole**: Cluster-wide permissions (e.g., view all nodes)
- **RoleBinding**: Grants Role to users/groups in a namespace
- **ClusterRoleBinding**: Grants ClusterRole cluster-wide
- **SCC (Security Context Constraints)**: Covered in Module 08; controls pod privileges

## Commands First

```bash
# View current authentication config
oc get oauth cluster -o yaml
oc get identity,user

# Configure HTPasswd IdP (create users file)
htpasswd -c -B -b /tmp/htpasswd ${ADMIN_USER} admin123
htpasswd -b /tmp/htpasswd ${DEV_USER} dev123
htpasswd -b /tmp/htpasswd viewer view123

# Create HTPasswd secret
oc create secret generic htpass-secret \
  --from-file=htpasswd=/tmp/htpasswd \
  -n openshift-config

# Add HTPasswd IdP to cluster OAuth
cat <<EOF | oc apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: ${IDP_NAME}
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
EOF

# Wait for OAuth pods to restart
oc get pods -n openshift-authentication -w

# Login as new user
oc login -u ${DEV_USER} -p dev123 ${CLUSTER_API}

# Create group and add users
oc adm groups new developers
oc adm groups add-users developers ${DEV_USER} user2 user3

# Grant cluster-admin (DANGER: full cluster access)
oc adm policy add-cluster-role-to-user cluster-admin ${ADMIN_USER}

# Grant project admin (safer: scoped to namespace)
oc adm policy add-role-to-user admin ${DEV_USER} -n ${NS}

# Grant view-only access
oc adm policy add-role-to-user view viewer -n ${NS}

# Grant custom role
oc create role pod-reader \
  --verb=get,list,watch \
  --resource=pods \
  -n ${NS}

oc create rolebinding dev-pod-reader \
  --role=pod-reader \
  --user=${DEV_USER} \
  -n ${NS}

# Test permissions
oc auth can-i create pods -n ${NS} --as=${DEV_USER}
oc auth can-i delete nodes --as=${DEV_USER}  # Should return "no"
oc auth can-i '*' '*' --as=${ADMIN_USER}  # Cluster-admin can do everything

# List role bindings
oc get rolebindings -n ${NS}
oc get clusterrolebindings | grep ${ADMIN_USER}

# Describe role permissions
oc describe clusterrole admin
oc describe role pod-reader -n ${NS}

# Remove access
oc adm policy remove-role-from-user admin ${DEV_USER} -n ${NS}
oc adm policy remove-cluster-role-from-user cluster-admin ${ADMIN_USER}

# Delete user (DANGER: must also remove identity and OAuth entry)
oc delete user ${DEV_USER}
oc delete identity ${IDP_NAME}:${DEV_USER}
```

**Why/Notes**: HTPasswd is simple for testing; LDAP/OAuth for production. Always use RoleBindings for namespace-scoped access. Avoid cluster-admin unless necessary. Test permissions with `oc auth can-i` before granting.

## Verify

```bash
# Check IdP configured
oc get oauth cluster -o jsonpath='{.spec.identityProviders[*].name}'

# Verify users and groups
oc get users
oc get groups
oc describe group developers

# Test user login
oc login -u ${DEV_USER} -p dev123
oc whoami
oc whoami --show-console  # Web console URL

# Verify RBAC bindings
oc get rolebindings,clusterrolebindings -A | grep ${DEV_USER}
oc auth can-i get pods -n ${NS} --as=${DEV_USER}
oc auth can-i create projects --as=${DEV_USER}
```

Expected: Users created, IdP active, RoleBindings grant expected permissions, `oc auth can-i` returns correct yes/no.

## Mini-Lab (5-10 min)

**Scenario**: Configure HTPasswd IdP, create admin and developer users, grant scoped permissions.

1. **Create users file**:

```bash
htpasswd -c -B -b /tmp/lab-htpasswd admin admin123
htpasswd -b /tmp/lab-htpasswd dev1 dev123
htpasswd -b /tmp/lab-htpasswd dev2 dev456
htpasswd -b /tmp/lab-htpasswd readonly view123
```

2. **Configure OAuth** (as cluster-admin):

```bash
oc create secret generic lab-htpass \
  --from-file=htpasswd=/tmp/lab-htpasswd \
  -n openshift-config

oc get oauth cluster -o yaml > /tmp/oauth-backup.yaml  # Backup

oc patch oauth cluster --type=merge -p '
{
  "spec": {
    "identityProviders": [{
      "name": "lab-htpasswd",
      "mappingMethod": "claim",
      "type": "HTPasswd",
      "htpasswd": {
        "fileData": {
          "name": "lab-htpass"
        }
      }
    }]
  }
}'

# Wait for authentication pods to restart
oc get pods -n openshift-authentication
sleep 30
```

3. **Grant permissions**:

```bash
# admin user gets cluster-admin (full access)
oc adm policy add-cluster-role-to-user cluster-admin admin

# dev1 gets admin in demo project
oc new-project demo-rbac
oc adm policy add-role-to-user admin dev1 -n demo-rbac

# dev2 gets edit (can modify but not manage RBAC)
oc adm policy add-role-to-user edit dev2 -n demo-rbac

# readonly gets view (read-only)
oc adm policy add-role-to-user view readonly -n demo-rbac
```

4. **Test permissions**:

```bash
# Login as dev1
oc login -u dev1 -p dev123
oc new-project dev1-test  # Should succeed
oc create deployment nginx --image=nginx -n demo-rbac
oc get rolebindings -n demo-rbac  # Should see bindings

# Login as dev2
oc login -u dev2 -p dev456
oc new-project dev2-test  # Likely fails (no self-provisioner by default)
oc create deployment test --image=nginx -n demo-rbac  # Should succeed
oc delete rolebinding admin -n demo-rbac  # Should fail (no admin rights)

# Login as readonly
oc login -u readonly -p view123
oc get pods -n demo-rbac  # Should succeed
oc delete pod nginx-xyz -n demo-rbac  # Should fail

# Test with can-i (as cluster-admin)
oc login -u admin -p admin123
oc auth can-i create pods -n demo-rbac --as=dev1  # yes
oc auth can-i delete rolebindings -n demo-rbac --as=dev2  # no
oc auth can-i get pods -n demo-rbac --as=readonly  # yes
oc auth can-i delete pods -n demo-rbac --as=readonly  # no
```

5. **Create custom role**:

```bash
oc create role log-reader \
  --verb=get,list \
  --resource=pods,pods/log \
  -n demo-rbac

oc create rolebinding readonly-logs \
  --role=log-reader \
  --user=readonly \
  -n demo-rbac

# Test
oc login -u readonly -p view123
oc logs <pod-name> -n demo-rbac  # Should succeed
```

## Quiz (5 Questions)

1. **Q**: What's the difference between Role and ClusterRole?  
   **A**: Role is namespace-scoped; ClusterRole is cluster-wide.

2. **Q**: How do you test if a user can perform an action?  
   **A**: `oc auth can-i <verb> <resource> --as=<user> -n <namespace>`

3. **Q**: What does `cluster-admin` ClusterRole grant?  
   **A**: Full unrestricted access to all resources cluster-wide (superuser).

4. **Q**: How do you remove a user's admin access to a namespace?  
   **A**: `oc adm policy remove-role-from-user admin <user> -n <namespace>`

5. **Q**: What's the default identity mapping method for HTPasswd?  
   **A**: `claim` (username from IdP becomes OpenShift username).

## Common Mistakes

- **Granting cluster-admin broadly**: Use project-scoped `admin` role instead.
- **Forgetting to wait for OAuth pods**: Changes take 30-60s to apply; test after restart.
- **Deleting user without identity**: Must delete both `User` and `Identity` objects.
- **Not using groups**: Managing individual user bindings doesn't scale; use groups.
- **Testing permissions as cluster-admin**: Always test as the target user with `--as` flag.

## Troubleshooting

See [Triage Matrix: Auth & RBAC Issues](../troubleshooting/triage-matrix.md#auth-rbac)

**Symptom**: User login fails with "invalid username or password"  
**Triage**: `oc get oauth cluster -o yaml` shows IdP config; check secret exists  
**Fix**: Verify htpasswd secret content matches user/pass; recreate secret if needed  
**Prevent**: Test with `htpasswd -v /tmp/htpasswd <user>` before creating secret

**Symptom**: `oc auth can-i` returns "no" but user claims they have access  
**Triage**: `oc get rolebindings,clusterrolebindings -A | grep <user>` shows no bindings  
**Fix**: Grant appropriate role with `oc adm policy add-role-to-user`  
**Prevent**: Document RBAC changes; use groups instead of individual users

---

**Next**: [Module 04: Network Security](04-network-security.md)

# DevOps Project

A comprehensive collection of DevOps resources including command references and interview preparation materials.

## Resources

### 📚 [DevOps Commands Bible](DevOps-Commands-Bible.md)
A complete reference guide with **451+ commands** across 10 critical DevOps topics. Each command includes:
- The exact command syntax
- A concise description
- Practical explanation of when and why to use it

### 💬 [DevOps Interview Q&A](DevOps-Interview-QA.md)
Curated interview questions with crisp one-liner answers covering **316 scenarios** across:
- Real-world troubleshooting scenarios
- Common gotchas and pitfalls
- Security and cost optimization
- Command explanations
- Advanced design tradeoffs

### 🎓 [OpenShift 4.x Administration & Operations Course](course/00-overview.md)
Complete, command-first training course for OpenShift administrators and SREs. Features:
- **10 comprehensive modules** with hands-on labs and quizzes
- **Capstone project**: Deploy FoodCart microservices with Kustomize overlays (dev/prod)
- **Troubleshooting pack**: Systematic triage matrix for common Day-2 issues
- **Cheatsheets**: oc CLI, YAML snippets, oc adm operations
- **2 mock exams**: 60-minute timed exams with solutions (EX280 prep)
- **CLI-focused**: All tasks use `oc`, `kubectl`, `helm`, `oc adm` commands

## Contents

### DevOps Commands Bible
1. **Linux** (64 commands) - System administration, networking, storage, processes, users/groups
2. **Bash** (53 commands) - Shell scripting, variables, loops, functions, redirections
3. **Git & GitHub** (50 commands) - Version control, branching, merging, collaboration
4. **AWS CLI** (44 commands) - Cloud infrastructure, S3, EC2, IAM, EKS, CloudWatch
5. **Terraform** (35 commands) - Infrastructure as Code, state management, workspaces
6. **Ansible** (34 commands) - Configuration management, playbooks, ad-hoc commands
7. **Kubernetes** (73 commands) - Container orchestration, kubectl, helm, cluster management
8. **GitLab CI/CD** (33 commands) - Pipeline management, runners, variables
9. **GitHub Actions** (34 commands) - Workflows, runs, secrets, artifacts
10. **Prometheus** (31 commands) - Monitoring, metrics, PromQL queries

### OpenShift Course Modules
1. **[Module 00: Overview](course/00-overview.md)** - Course introduction, environment setup, module map
2. **[Module 01: Declarative Resource Management](course/01-declarative-resource-management.md)** - oc apply, Kustomize, labels, dry-run
3. **[Module 02: Deploy Packaged Applications](course/02-deploy-packaged-apps.md)** - Templates, Helm, ImageStreams
4. **[Module 03: Authentication & Authorization](course/03-authentication-and-authorization.md)** - IdP, RBAC, users/groups
5. **[Module 04: Network Security](course/04-network-security.md)** - Routes, TLS, NetworkPolicies
6. **[Module 05: Non-HTTP & SNI Applications](course/05-non-http-and-sni-apps.md)** - Services, NodePort, LoadBalancer
7. **[Module 06: Developer Self-Service](course/06-developer-self-service.md)** - Quotas, LimitRanges, project templates
8. **[Module 07: Operators & OLM](course/07-operators-and-olm.md)** - Install, upgrade, CRs, troubleshooting
9. **[Module 08: Application Security & SCC](course/08-application-security-and-scc.md)** - SCCs, ServiceAccounts, secrets
10. **[Module 09: Cluster Updates & Maintenance](course/09-cluster-updates-and-maintenance.md)** - Upgrades, drains, backups, registry
11. **[Module 10: Comprehensive Review](course/10-comprehensive-review.md)** - Scenarios, drills, final checklist
12. **[Capstone Project: FoodCart App](project/README.md)** - Full-stack microservices with Kustomize
13. **[Troubleshooting Triage Matrix](troubleshooting/triage-matrix.md)** - Systematic issue resolution
14. **[Cheatsheets](cheatsheets/)** - oc CLI, YAML snippets, oc adm ops
15. **[Mock Exams](exams/)** - Two 60-minute timed practice exams

## Features

- ✅ **One-liner format** - Quick reference without clutter
- ✅ **Safety warnings** - [DANGER] tags on risky operations
- ✅ **Distro-specific** - [Ubuntu] and [RHEL] variants where applicable
- ✅ **Standardized placeholders** - `${VAR}`, `${REGION}`, `${CLUSTER}`, etc.
- ✅ **CLI-focused** - Command-line tools only, no YAML/config files
- ✅ **Troubleshooting included** - Debug commands alongside core operations

## Usage

### For Command Reference
Open [DevOps-Commands-Bible.md](DevOps-Commands-Bible.md) to access all commands. Use your editor's search functionality to quickly find specific commands or topics.

### For Interview Preparation
Open [DevOps-Interview-QA.md](DevOps-Interview-QA.md) to study practical Q&A scenarios. Each table is organized by topic with questions tagged by type (SCENARIO, GOTCHA, SECURITY, CMD, etc.).

### Example Commands

```bash
# Linux - Check disk space
df -h

# Kubernetes - Get all pods across namespaces
kubectl get pods -A

# AWS - Assume IAM role
aws sts assume-role --role-arn ${ARN} --role-session-name ${NAME}

# Terraform - Plan without applying
terraform plan -out=plan.tfplan

# Prometheus - Query API
curl '${PROMETHEUS_URL}/api/v1/query?query=up'
```

## Audience

- **DevOps Engineers** preparing for interviews and certifications
- **System Administrators** learning cloud-native tools
- **SREs** building infrastructure automation and managing production clusters
- **Platform Engineers** managing Kubernetes and OpenShift clusters
- **OpenShift Administrators** preparing for Red Hat EX280 certification
- **Technical Interviewers** looking for standardized questions
- **Anyone** needing quick command references and troubleshooting guides

## Contributing

This is a curated reference guide. Commands follow production best practices with safe defaults.

## License

This documentation is provided as-is for educational and professional reference purposes.

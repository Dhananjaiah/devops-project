# DevOps Commands Bible

A comprehensive, exam-ready command catalog for DevOps engineers covering essential tools and platforms.

## Overview

This repository contains a complete reference guide with **451+ commands** across 10 critical DevOps topics. Each command includes:
- The exact command syntax
- A concise description
- Practical explanation of when and why to use it

## Contents

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

## Features

- ✅ **One-liner format** - Quick reference without clutter
- ✅ **Safety warnings** - [DANGER] tags on risky operations
- ✅ **Distro-specific** - [Ubuntu] and [RHEL] variants where applicable
- ✅ **Standardized placeholders** - `${VAR}`, `${REGION}`, `${CLUSTER}`, etc.
- ✅ **CLI-focused** - Command-line tools only, no YAML/config files
- ✅ **Troubleshooting included** - Debug commands alongside core operations

## Usage

Open [DevOps-Commands-Bible.md](DevOps-Commands-Bible.md) to access all commands. Use your editor's search functionality to quickly find specific commands or topics.

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

- DevOps Engineers preparing for certifications
- System Administrators learning cloud-native tools
- SREs building infrastructure automation
- Platform Engineers managing Kubernetes clusters
- Anyone needing a quick command reference

## Contributing

This is a curated reference guide. Commands follow production best practices with safe defaults.

## License

This documentation is provided as-is for educational and professional reference purposes.

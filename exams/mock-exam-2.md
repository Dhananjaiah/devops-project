# Mock Exam 2: Advanced MLOps

**Time: 90 minutes | 12 tasks**

## Instructions
- Builds on Mock Exam 1
- More complex, integrated tasks
- Focus on end-to-end workflows
- Solutions provided at end

## Tasks

### Task 1: Complete Pipeline (15 min)
Build end-to-end pipeline: data ingestion → validation → training → registration → deployment.

### Task 2: Monitoring Dashboard (10 min)
Create Grafana dashboard with request rate, latency (p50, p95), and error rate panels.

### Task 3: Drift Detection Pipeline (10 min)
Implement automated drift detection comparing production vs. baseline data.

### Task 4: CI/CD Workflow (15 min)
Create GitHub Actions workflow: lint → test → build → scan → deploy to dev → manual approval → deploy to prod.

### Task 5: Production Deployment (10 min)
Deploy model API to Kubernetes with HPA, TLS ingress, health checks, and external secrets.

### Task 6: Vulnerability Remediation (5 min)
Run security scans (Trivy, Gitleaks), identify vulnerabilities, fix or document exceptions.

### Task 7: Cost Optimization (10 min)
Add resource requests/limits to Kubernetes deployments, implement pod disruption budgets.

### Task 8: Model Card Creation (5 min)
Document model performance, limitations, ethical considerations, and maintenance plan.

### Task 9: Rollback Procedure (5 min)
Simulate failed deployment, perform rollback to previous stable version.

### Task 10: Load Testing (10 min)
Generate 1000 requests/sec, verify p95 latency < 100ms, check autoscaling behavior.

### Task 11: Automated Retraining (10 min)
Detect drift, trigger retraining pipeline, evaluate new model, register as challenger.

### Task 12: Documentation (5 min)
Write comprehensive README with quickstart, architecture diagram, troubleshooting guide.

## Solutions

See `mock-exam-2-solutions.md` for detailed solutions.

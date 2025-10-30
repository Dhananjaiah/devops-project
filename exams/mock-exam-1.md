# Mock Exam 1: MLOps Fundamentals

**Time: 90 minutes | 15 tasks**

## Instructions
- Complete all tasks in order
- Each task has time estimate
- Solutions provided at end
- Use local environment (no cloud required)

## Tasks

### Task 1: Environment Setup (5 min)
Create MLOps project structure with Git, DVC, and Python 3.11 virtual environment.

### Task 2: Data Versioning (5 min)
Generate 1000-row CSV dataset with features `x`, `y`. Track with DVC using local remote.

### Task 3: Experiment Tracking (10 min)
Train Logistic Regression model, log parameters and metrics to MLflow.

### Task 4: Model Registry (5 min)
Register the best performing model from Task 3 in MLflow Model Registry.

### Task 5: FastAPI Serving (10 min)
Create FastAPI application with `/health` and `/predict` endpoints.

### Task 6: Dockerfile (10 min)
Write Dockerfile for FastAPI app, build and test locally.

### Task 7: Airflow DAG (10 min)
Create Airflow DAG with 3 sequential tasks: prepare → train → evaluate.

### Task 8: Prometheus Metrics (10 min)
Add Prometheus metrics to FastAPI app (`/metrics` endpoint).

### Task 9: Drift Detection (10 min)
Write script using Evidently to detect data drift.

### Task 10: Kubernetes Deployment (5 min)
Create Kubernetes Deployment YAML with 2 replicas.

### Task 11: HPA Configuration (5 min)
Add HorizontalPodAutoscaler to scale 2-10 replicas at 70% CPU.

### Task 12: Security Scan (5 min)
Scan Docker container with Trivy, fail on HIGH/CRITICAL vulnerabilities.

### Task 13: Secret Management (5 min)
Create .gitleaksignore and configure Gitleaks to ignore false positives.

### Task 14: SBOM Generation (5 min)
Generate Software Bill of Materials using Syft.

### Task 15: Pre-commit Hooks (5 min)
Configure pre-commit with ruff formatter and gitleaks hooks.

## Solutions

See `mock-exam-1-solutions.md` for detailed solutions.

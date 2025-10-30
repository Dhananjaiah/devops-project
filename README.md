# DevOps & MLOps Resources

A comprehensive collection of DevOps resources and a complete MLOps course from beginner to production.

## 📚 Contents

### 1. [MLOps Course](MLOps-Course.md) ⭐ NEW
**Complete MLOps course from beginner to production in a single markdown file**

- 14 comprehensive chapters covering the entire MLOps lifecycle
- Hands-on labs with real commands (copy-paste ready)
- Docker Compose local stack for learning
- Kubernetes production deployment guides
- Capstone project: Full churn prediction system
- Troubleshooting guides and cheat sheets
- 2 mock exams with solutions

**Topics covered:**
- Environment setup & packaging
- Data versioning with DVC
- Experiment tracking with MLflow
- Model training & evaluation
- Pipeline orchestration (Airflow/Kubeflow)
- Model registry & governance
- CI/CD for ML (GitHub Actions)
- Model serving (FastAPI/KServe)
- Monitoring (Prometheus/Grafana)
- Drift detection & retraining
- Security, privacy & cost optimization

### 2. [DevOps Commands Bible](DevOps-Commands-Bible.md)
A complete reference guide with **451+ commands** across 10 critical DevOps topics:

- Linux (64 commands) - System administration, networking, storage
- Bash (53 commands) - Shell scripting, loops, functions
- Git & GitHub (50 commands) - Version control, branching
- AWS CLI (44 commands) - Cloud infrastructure, S3, EC2, EKS
- Terraform (35 commands) - Infrastructure as Code
- Ansible (34 commands) - Configuration management
- Kubernetes (73 commands) - Container orchestration
- GitLab CI/CD (33 commands) - Pipeline management
- GitHub Actions (34 commands) - Workflows, automation
- Prometheus (31 commands) - Monitoring, metrics

### 3. [DevOps Interview Q&A](DevOps-Interview-QA.md)
Curated interview questions with crisp answers covering **316 scenarios**:

- Real-world troubleshooting scenarios
- Common gotchas and pitfalls
- Security and cost optimization
- Command explanations
- Advanced design tradeoffs

## 🚀 Quick Start

### For MLOps Course
```bash
# Clone repository
git clone https://github.com/Dhananjaiah/devops-project.git
cd devops-project

# Read the complete course
cat MLOps-Course.md

# Or start with the hands-on project
cd project
docker compose up -d

# Access services:
# - MLflow: http://localhost:5000
# - Airflow: http://localhost:8080 (admin/admin)
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3000 (admin/admin)
```

### For DevOps Commands
Open [DevOps-Commands-Bible.md](DevOps-Commands-Bible.md) and use your editor's search to quickly find specific commands.

### For Interview Prep
Open [DevOps-Interview-QA.md](DevOps-Interview-QA.md) to study practical Q&A scenarios.

## 📂 Project Structure

```
.
├── MLOps-Course.md                 # Complete MLOps course (single file)
├── DevOps-Commands-Bible.md        # Command reference guide
├── DevOps-Interview-QA.md          # Interview Q&A
├── project/                        # MLOps capstone project
│   ├── docker-compose.yml          # Local development stack
│   ├── src/                        # Source code (data, models, serving)
│   ├── infra/                      # Infrastructure as Code
│   │   ├── prometheus/             # Monitoring configs
│   │   └── k8s/                    # Kubernetes manifests
│   └── README.md                   # Project documentation
├── troubleshooting/                # Troubleshooting guides
│   └── triage-matrix.md            # Systematic debugging guide
├── cheatsheets/                    # Quick reference sheets
│   ├── python-env.md               # Python environment management
│   ├── dvc-mlflow.md               # DVC & MLflow commands
│   ├── docker-k8s.md               # Docker & Kubernetes
│   ├── airflow-kfp.md              # Airflow & Kubeflow
│   └── monitoring.md               # Prometheus & Grafana
└── exams/                          # Mock exams for practice
    ├── mock-exam-1.md              # MLOps fundamentals
    └── mock-exam-2.md              # Advanced MLOps
```

## 🎯 Who Is This For?

- **MLOps Engineers** learning production ML systems
- **Data Scientists** wanting to deploy models reliably
- **DevOps Engineers** preparing for interviews and certifications
- **System Administrators** learning cloud-native tools
- **SREs** building infrastructure automation
- **Platform Engineers** managing Kubernetes clusters
- **Anyone** needing quick command references and best practices

## ✨ Features

### MLOps Course Features
- ✅ **Commands-first approach** - Learn by doing
- ✅ **Single markdown file** - Easy to search and navigate
- ✅ **Local development stack** - No cloud account needed to start
- ✅ **Production-ready patterns** - Scale from laptop to Kubernetes
- ✅ **Comprehensive coverage** - All aspects of MLOps lifecycle
- ✅ **Workflow diagrams** - Mermaid diagrams for visual learning
- ✅ **Hands-on labs** - 5-10 minute exercises per chapter
- ✅ **Quizzes & exams** - Test your understanding
- ✅ **Troubleshooting guides** - Debug common issues
- ✅ **Security best practices** - Scanning, secrets management

### DevOps Commands Features
- ✅ **One-liner format** - Quick reference without clutter
- ✅ **Safety warnings** - [DANGER] tags on risky operations
- ✅ **Distro-specific** - [Ubuntu] and [RHEL] variants where applicable
- ✅ **Standardized placeholders** - `${VAR}`, `${REGION}`, `${CLUSTER}`, etc.
- ✅ **CLI-focused** - Command-line tools only
- ✅ **Troubleshooting included** - Debug commands alongside core operations

## 🛠️ Technologies Covered

**MLOps Stack:**
- **Languages**: Python 3.11+
- **Packaging**: uv, Poetry
- **Data**: DVC, Pandas, Great Expectations
- **ML**: scikit-learn, MLflow
- **Orchestration**: Airflow, Kubeflow Pipelines
- **Serving**: FastAPI, KServe, BentoML
- **Containers**: Docker, Kubernetes
- **Monitoring**: Prometheus, Grafana, Evidently
- **IaC**: Terraform, Kustomize, Helm
- **CI/CD**: GitHub Actions, GitLab CI
- **Security**: Trivy, Gitleaks, Syft, Grype

**DevOps Tools:**
- Linux, Bash scripting
- Git, GitHub, GitLab
- AWS CLI, Terraform, Ansible
- Docker, Kubernetes, Helm
- Prometheus, Grafana
- CI/CD pipelines

## 📖 Learning Path

### Recommended Order for MLOps:
1. **Start**: Chapter 0 (Orientation) - Quick docker-compose stack
2. **Foundations**: Chapters 1-3 - Project structure, environment, data
3. **ML Basics**: Chapters 4-6 - Experiments, features, training
4. **Automation**: Chapters 7-9 - Pipelines, registry, CI/CD
5. **Production**: Chapters 10-12 - Serving, monitoring, drift
6. **Advanced**: Chapter 13 - Security, privacy, cost
7. **Practice**: Chapter 14 (Review) + Capstone + Mock Exams

### For DevOps:
1. Master Linux & Bash basics
2. Learn Git workflows thoroughly
3. Practice with cloud CLI (AWS/GCP/Azure)
4. Build with IaC (Terraform)
5. Deploy with containers (Docker/K8s)
6. Automate with CI/CD
7. Monitor everything (Prometheus)

## 🤝 Contributing

This is a curated reference guide. Commands follow production best practices with safe defaults.

## 📄 License

This documentation is provided as-is for educational and professional reference purposes.

## 🌟 Highlights

- **6,000+ lines** of MLOps course content
- **451+ DevOps commands** across 10 tools
- **316 interview questions** with answers
- **Real-world examples** tested in production
- **Copy-paste ready** commands and configs
- **Beginner to expert** coverage
- **Completely offline-capable** after clone

---

**Get Started:** Read [MLOps-Course.md](MLOps-Course.md) to begin your MLOps journey! 🚀

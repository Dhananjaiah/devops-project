# MLOps Course: Beginner → Production

**Complete MLOps 0→1→Production Course**  
From absolute beginner to production-grade ML systems.

---

## ASSUMED VARIABLES (Defaults)

```bash
export CLOUD="local"                    # Deployment target: local|aws|gcp|azure
export REGION="us-east-1"               # Cloud region
export REGISTRY="ghcr.io/myorg"         # Container registry
export BUCKET="mlops-artifacts"         # Object storage bucket
export CLUSTER="mlops-dev"              # Kubernetes cluster name
export NAMESPACE="mlops"                # Kubernetes namespace
export DB_URL="postgres://mlops:mlops@db:5432/mlops"  # Database connection
export TRACKING_URL="http://mlflow:5000"              # MLflow tracking server
export MODEL_NAME="churn-predictor"     # Default model name
export PROJECT="mlops-course"           # Project name
export PY_VER="3.11"                    # Python version
```

---

## GLOBAL GLOSSARY

**One-line definitions for every term:**

- **Model**: Mathematical function trained on data to make predictions.
- **Dataset**: Collection of data samples used for training/testing ML models.
- **Feature**: Individual measurable property used as input to a model.
- **Experiment**: Single training run with specific hyperparameters tracked for comparison.
- **Artifact**: File output from a pipeline (model, dataset, plot, report).
- **Pipeline**: Automated sequence of data/ML processing steps.
- **DAG**: Directed Acyclic Graph—workflow where tasks depend on others without cycles.
- **Step/Task**: Single unit of work in a pipeline (e.g., preprocess, train).
- **Training**: Process of learning model parameters from data.
- **Inference**: Using a trained model to make predictions on new data.
- **Batch vs Online**: Batch=scheduled bulk predictions; Online=real-time per-request predictions.
- **Registry**: Central store for versioned, approved ML models.
- **Deployment**: Process of making a model available for inference.
- **Canary**: Deploy new version to small traffic subset before full rollout.
- **Blue-Green**: Run two environments (old/new); switch traffic instantly.
- **Rollback**: Revert to previous model/deployment version after issue.
- **Monitoring**: Tracking metrics (latency, errors, drift) from deployed systems.
- **Data Drift**: Statistical distribution change in input features over time.
- **Concept Drift**: Change in relationship between features and target (model degrades).
- **Feature Store**: Central repository for computed, reusable features.
- **Feature View**: Logical grouping of features for a specific ML use case.
- **Model Card**: Document describing model purpose, performance, limitations, ethics.
- **Governance**: Policies ensuring models are compliant, auditable, and approved.
- **SBOM**: Software Bill of Materials—list of dependencies for security audits.
- **CI**: Continuous Integration—automated testing on every code commit.
- **CD**: Continuous Deployment/Delivery—automated release to environments.
- **IaC**: Infrastructure as Code—managing infra via version-controlled config files.
- **Orchestrator**: Tool scheduling/executing pipeline tasks (Airflow, Kubeflow).
- **p95 Latency**: 95th percentile response time (95% of requests faster than this).
- **SLA/SLO/SLI**: Service Level Agreement/Objective/Indicator—uptime/performance targets.
- **Shadow Deploy**: Route copy of live traffic to new model for validation without impacting users.
- **A/B Test**: Compare two model versions by routing random traffic splits.

---

## CORE WORKFLOWS

### 1. Data Workflow

```mermaid
graph LR
    A[Raw Data] --> B[Ingest]
    B --> C[Validate Schema]
    C --> D[Version with DVC]
    D --> E[Feature Engineering]
    E --> F[Publish to Store]
    F --> G[Training Pipeline]
```

**Explanation**: Raw data is ingested → validated against schema → versioned (DVC) → features computed → stored centrally → consumed by training.

---

### 2. Experiment Workflow

```mermaid
graph LR
    A[Code + Data] --> B[Prepare Env]
    B --> C[Train Model]
    C --> D[Evaluate Metrics]
    D --> E[Log to MLflow]
    E --> F[Compare Runs]
    F --> G[Select Best]
```

**Explanation**: Prepare environment → train model → evaluate metrics → log everything to MLflow → compare experiments → pick winner.

---

### 3. Training Pipeline Workflow

```mermaid
graph LR
    A[Fetch Data] --> B[Transform Features]
    B --> C[Train Model]
    C --> D[Validate Output]
    D --> E[Register Model]
    E --> F[Staging/Prod]
```

**Explanation**: Pipeline fetches data → applies transformations → trains → validates model quality → registers in MLflow → transitions to staging/prod.

---

### 4. Deployment (CI/CD) Workflow

```mermaid
graph LR
    A[Code Push] --> B[Test Suite]
    B --> C[Build Container]
    C --> D[Security Scan]
    D --> E[Push Registry]
    E --> F[Deploy Dev]
    F --> G[Manual Approve]
    G --> H[Deploy Prod]
```

**Explanation**: Code commit → automated tests → container build → security scan (Trivy) → push to registry → deploy dev → manual gate → prod.

---

### 5. Online Inference Workflow

```mermaid
graph LR
    A[Request] --> B[Feature Fetch]
    B --> C[Load Model]
    C --> D[Predict]
    D --> E[Log Prediction]
    E --> F[Return Response]
    F --> G[Monitor Metrics]
```

**Explanation**: Request arrives → fetch features → load model → predict → log input/output → return response → track latency/errors.

---

### 6. Monitoring & Retraining Workflow

```mermaid
graph LR
    A[Collect Metrics] --> B[Detect Drift]
    B --> C[Trigger Retrain]
    C --> D[Review Model]
    D --> E[Approve & Promote]
    E --> F[Deploy Updated]
```

**Explanation**: Monitor metrics → drift detector fires alert → trigger retraining pipeline → review new model → approve → deploy updated version.

---

# CHAPTER 0: ORIENTATION FOR BEGINNERS

## What is MLOps?

**Definition**: MLOps = Machine Learning + DevOps. Set of practices to deploy and maintain ML models in production reliably and efficiently.

**Why MLOps?**  
- Manual model deployment is error-prone and slow.  
- Models degrade over time (drift); need automated monitoring/retraining.  
- Collaboration requires versioning data, code, and models.  
- Compliance needs auditable pipelines and governance.

**Roles in MLOps:**  
- **Data Engineer**: Build data pipelines, ensure data quality.  
- **ML Engineer**: Train models, tune hyperparameters, track experiments.  
- **MLOps Engineer**: Automate training/deployment, manage infra, monitor production.  
- **Platform Engineer**: Build self-service ML platforms (Kubernetes, feature stores).

**Learning Path:**  
1. Learn Linux/bash, Git, Docker basics.  
2. Understand Python packaging, virtual environments.  
3. Practice data versioning (DVC), experiment tracking (MLflow).  
4. Build simple training pipeline (local).  
5. Deploy model as API (FastAPI).  
6. Add monitoring (Prometheus/Grafana).  
7. Scale to Kubernetes (KServe/Kubeflow).

---

## Local Docker Compose Quickstart

### Definitions

- **Docker Compose**: Tool to define multi-container apps in YAML; start with one command.  
- **MinIO**: S3-compatible object storage for local development.  
- **MLflow**: Experiment tracking and model registry server.  
- **Postgres**: Relational database for MLflow backend.  
- **Airflow**: Workflow orchestrator for scheduling pipelines.

### Commands

**1. Create project directory**

```bash
mkdir -p ~/mlops-quickstart && cd ~/mlops-quickstart
```

**2. Create docker-compose.yml**

```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  minio:
    image: minio/minio:latest
    container_name: minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 10s
      timeout: 5s
      retries: 3

  postgres:
    image: postgres:15-alpine
    container_name: mlflow-db
    environment:
      POSTGRES_USER: mlops
      POSTGRES_PASSWORD: mlops
      POSTGRES_DB: mlops
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mlops"]
      interval: 10s
      timeout: 5s
      retries: 5

  mlflow:
    image: ghcr.io/mlflow/mlflow:latest
    container_name: mlflow
    command: >
      mlflow server 
      --backend-store-uri postgresql://mlops:mlops@postgres:5432/mlops
      --default-artifact-root s3://mlflow-artifacts/
      --host 0.0.0.0
      --port 5000
    environment:
      MLFLOW_S3_ENDPOINT_URL: http://minio:9000
      AWS_ACCESS_KEY_ID: minioadmin
      AWS_SECRET_ACCESS_KEY: minioadmin
    ports:
      - "5000:5000"
    depends_on:
      postgres:
        condition: service_healthy
      minio:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 10s
      timeout: 5s
      retries: 5

  airflow-init:
    image: apache/airflow:2.7.3-python3.11
    container_name: airflow-init
    environment:
      AIRFLOW__CORE__EXECUTOR: LocalExecutor
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql+psycopg2://mlops:mlops@postgres:5432/mlops
      AIRFLOW__CORE__FERNET_KEY: ''
      AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION: 'true'
      AIRFLOW__CORE__LOAD_EXAMPLES: 'false'
      _AIRFLOW_DB_MIGRATE: 'true'
      _AIRFLOW_WWW_USER_CREATE: 'true'
      _AIRFLOW_WWW_USER_USERNAME: admin
      _AIRFLOW_WWW_USER_PASSWORD: admin
    command: version
    depends_on:
      postgres:
        condition: service_healthy

  airflow:
    image: apache/airflow:2.7.3-python3.11
    container_name: airflow
    environment:
      AIRFLOW__CORE__EXECUTOR: LocalExecutor
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql+psycopg2://mlops:mlops@postgres:5432/mlops
      AIRFLOW__CORE__FERNET_KEY: ''
      AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION: 'true'
      AIRFLOW__CORE__LOAD_EXAMPLES: 'false'
    ports:
      - "8080:8080"
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    command: webserver
    depends_on:
      - airflow-init
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    image: python:3.11-slim
    container_name: mlops-api
    working_dir: /app
    command: bash -c "pip install fastapi uvicorn && uvicorn main:app --host 0.0.0.0 --port 8000"
    ports:
      - "8000:8000"
    volumes:
      - ./api:/app
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  minio_data:
  postgres_data:
EOF
```

**3. Create placeholder FastAPI app**

```bash
mkdir -p api
cat > api/main.py << 'EOF'
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.post("/predict")
def predict(data: dict):
    # Placeholder prediction
    return {"prediction": 0, "model": "churn-predictor-v1"}
EOF
```

**4. Create DAGs directory**

```bash
mkdir -p dags logs plugins
```

**5. Start the stack**

```bash
docker compose up -d
```

### Verify

```bash
# Check all services running
docker ps

# Expected output:
# minio (9000, 9001)
# postgres (5432)
# mlflow (5000)
# airflow (8080)
# api (8000)

# Test MLflow
curl http://localhost:5000/health
# Expected: healthy

# Test API
curl http://localhost:8000/health
# Expected: {"status":"healthy"}

# Access UIs:
# MinIO: http://localhost:9001 (minioadmin/minioadmin)
# MLflow: http://localhost:5000
# Airflow: http://localhost:8080 (admin/admin)
```

### Notes

- Stack includes MLflow (tracking), MinIO (artifacts), Postgres (backend), Airflow (orchestration), API (serving).  
- All services use health checks; `depends_on` ensures start order.  
- Data persists in Docker volumes; survives restarts.  
- To stop: `docker compose down` (add `-v` to delete volumes).

### Mini-Lab (10 min)

**Objective**: Log a dummy experiment to MLflow.

1. Install MLflow client:
   ```bash
   pip install mlflow
   ```

2. Create experiment script:
   ```bash
   cat > test_experiment.py << 'EOF'
   import mlflow
   import os
   
   os.environ["MLFLOW_TRACKING_URI"] = "http://localhost:5000"
   os.environ["MLFLOW_S3_ENDPOINT_URL"] = "http://localhost:9000"
   os.environ["AWS_ACCESS_KEY_ID"] = "minioadmin"
   os.environ["AWS_SECRET_ACCESS_KEY"] = "minioadmin"
   
   mlflow.set_experiment("quickstart")
   
   with mlflow.start_run():
       mlflow.log_param("learning_rate", 0.01)
       mlflow.log_metric("accuracy", 0.95)
       print("Logged experiment to MLflow!")
   EOF
   ```

3. Run experiment:
   ```bash
   python test_experiment.py
   ```

4. Open MLflow UI (http://localhost:5000), navigate to "quickstart" experiment, verify run logged.

**Expected outcome**: See one run with param `learning_rate=0.01` and metric `accuracy=0.95`.

### Quiz (5 Questions)

1. What does MLflow track?  
   → Experiments, parameters, metrics, artifacts, models.

2. Why use MinIO locally?  
   → S3-compatible object storage without AWS account.

3. What happens if you run `docker compose down -v`?  
   → Stops containers AND deletes volumes (data loss).

4. How do you check if MLflow is healthy?  
   → `curl http://localhost:5000/health` or check UI.

5. What is the purpose of `depends_on` in docker-compose?  
   → Ensures services start in correct order (e.g., DB before MLflow).

### Common Mistakes

- Forgetting to create `dags/` directory → Airflow fails to mount volume.  
- Using `docker compose down -v` accidentally → loses all tracked experiments.  
- Port conflicts (e.g., 5000 already in use) → change ports in `docker-compose.yml`.  
- Not setting S3 endpoint → MLflow can't store artifacts to MinIO.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- MLflow container restarting → check Postgres connectivity.  
- MinIO health check fails → increase timeout or check logs.  
- Airflow webserver 502 → wait for init job to finish.

---

# CHAPTER 1: FOUNDATIONS

## Definitions

- **ML Lifecycle**: Sequence from problem definition → data → training → deployment → monitoring → retraining.  
- **Experimentation Phase**: Exploratory work; frequent model iterations; track everything.  
- **Production Phase**: Stable, versioned, monitored models; automated pipelines.  
- **Model Versioning**: Assign unique identifiers (semantic or hash) to track model changes.  
- **Data Versioning**: Track datasets like code using tools (DVC, Git LFS).  
- **Reproducibility**: Ability to recreate exact results given same code/data/env.  
- **Artifact**: Output file from a pipeline stage (trained model, plot, report).  
- **Model Registry**: Central store for approved, versioned models ready for deployment.  
- **Staging vs Production**: Staging=pre-prod testing; Production=live user traffic.  
- **Metadata**: Data about data (schema, stats, lineage, provenance).  
- **Lineage**: History tracking which data/code/model versions produced an artifact.  
- **Experiment**: Single training run; combination of code, data, hyperparameters.  
- **Baseline Model**: Simple reference model (e.g., logistic regression) to beat.  
- **Overfitting**: Model performs well on training data but poorly on unseen data.  
- **Underfitting**: Model too simple; poor performance on both train and test.

## Repo Structure (Standard Layout)

```
mlops-project/
├── data/                  # Raw, processed, external datasets (versioned by DVC)
│   ├── raw/
│   ├── processed/
│   └── external/
├── notebooks/             # Jupyter notebooks for exploration
├── src/                   # Source code (training, inference, utils)
│   ├── __init__.py
│   ├── data/              # Data loading, validation, transforms
│   ├── features/          # Feature engineering
│   ├── models/            # Model definitions, training logic
│   └── serving/           # Inference APIs
├── pipelines/             # Orchestration DAGs (Airflow, Kubeflow)
├── tests/                 # Unit, integration tests
├── infra/                 # IaC (Terraform, Kubernetes YAML)
│   ├── terraform/
│   └── k8s/
├── scripts/               # Utility scripts (setup, deploy)
├── configs/               # Config files (YAML for experiments, deployments)
├── .dvc/                  # DVC metadata
├── .github/workflows/     # CI/CD pipelines
├── pyproject.toml         # Python dependencies (Poetry/uv)
├── Dockerfile             # Container image definition
├── docker-compose.yml     # Local dev stack
└── README.md              # Project documentation
```

## Commands

**1. Initialize project structure**

```bash
mkdir -p mlops-project/{data/{raw,processed,external},notebooks,src/{data,features,models,serving},pipelines,tests,infra/{terraform,k8s},scripts,configs}
cd mlops-project
```

**2. Initialize Git**

```bash
git init
git branch -M main
```

**3. Create .gitignore**

```bash
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
.Python
venv/
.venv/
*.egg-info/

# Data (version with DVC, not Git)
data/raw/*
data/processed/*
!data/raw/.gitkeep
!data/processed/.gitkeep

# Secrets
.env
*.key
*.pem

# IDEs
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# MLflow
mlruns/
mlartifacts/

# Airflow
logs/
airflow.db
airflow-webserver.pid
EOF
```

**4. Create Python package structure**

```bash
touch src/__init__.py src/data/__init__.py src/features/__init__.py src/models/__init__.py src/serving/__init__.py
```

**5. Initialize pyproject.toml (uv example)**

```bash
cat > pyproject.toml << 'EOF'
[project]
name = "mlops-project"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "numpy>=1.24",
    "pandas>=2.0",
    "scikit-learn>=1.3",
    "mlflow>=2.8",
    "fastapi>=0.104",
    "uvicorn>=0.24",
    "pydantic>=2.4",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4",
    "black>=23.0",
    "ruff>=0.1",
    "pre-commit>=3.5",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
EOF
```

**6. Install dependencies (using uv)**

```bash
# Install uv if not available
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create virtual environment and install
uv venv
source .venv/bin/activate  # or `.venv\Scripts\activate` on Windows
uv pip install -e ".[dev]"
```

### Verify

```bash
# Check repo structure
tree -L 2 -a

# Verify Python imports
python -c "import src; print('✓ Package imports work')"

# Check installed packages
uv pip list | grep mlflow
# Expected: mlflow 2.x.x
```

### Notes

- Use `.gitkeep` files to track empty directories in Git.  
- DVC will track large data files; Git tracks code only.  
- `pyproject.toml` is the modern standard (replaces `requirements.txt` + `setup.py`).  
- Virtual environments isolate dependencies per project.

### Mini-Lab (5 min)

**Objective**: Create a dummy dataset and track it with Git (not DVC yet).

1. Create sample data:
   ```bash
   mkdir -p data/raw
   echo "id,feature1,feature2,label" > data/raw/sample.csv
   echo "1,0.5,0.3,1" >> data/raw/sample.csv
   echo "2,0.2,0.8,0" >> data/raw/sample.csv
   ```

2. Check Git status:
   ```bash
   git status
   # Expected: data/raw/* ignored by .gitignore
   ```

3. Add `.gitkeep` to track directory:
   ```bash
   touch data/raw/.gitkeep
   git add data/raw/.gitkeep pyproject.toml .gitignore
   git commit -m "feat: initialize project structure"
   ```

**Expected outcome**: Git tracks directory structure but not CSV files.

### Quiz (5 Questions)

1. Why separate `data/` from `src/`?  
   → Data can be large (GB/TB); version separately with DVC, not Git.

2. What's the difference between staging and production?  
   → Staging=testing environment; Production=live users.

3. Why use `pyproject.toml` over `requirements.txt`?  
   → Modern standard; supports build config, metadata, and dev dependencies in one file.

4. What is an artifact?  
   → File output from a pipeline (model, plot, dataset).

5. What does reproducibility mean in ML?  
   → Same code/data/env produces identical results.

### Common Mistakes

- Committing large datasets to Git → use DVC or Git LFS.  
- Not using virtual environments → dependency conflicts across projects.  
- Hardcoding paths (e.g., `/home/user/data`) → use relative paths or env vars.  
- No .gitignore → accidentally commit secrets or cache files.

### Troubleshooting

See `/troubleshooting/triage-matrix.md`.

---

# CHAPTER 2: ENVIRONMENT & PACKAGING

## Definitions

- **Virtual Environment**: Isolated Python environment with its own packages.  
- **Dependency Resolution**: Finding compatible package versions that satisfy all requirements.  
- **Lock File**: Exact pinned versions of dependencies for reproducibility (`uv.lock`, `poetry.lock`).  
- **Base Image**: Docker image used as starting point (e.g., `python:3.11-slim`).  
- **Multi-stage Build**: Dockerfile with multiple `FROM` stages to reduce final image size.  
- **Layer Caching**: Docker reuses unchanged layers to speed up builds.  
- **Pre-commit Hook**: Script that runs before `git commit` to enforce code quality.  
- **Linter**: Tool that checks code style (e.g., `ruff`, `black`).  
- **Formatter**: Tool that automatically fixes code style.  
- **Type Checker**: Tool that validates Python type hints (e.g., `mypy`).  
- **Editable Install**: Install package in dev mode (`pip install -e .`) so changes reflect immediately.  
- **Pinning**: Locking dependency to exact version (`pandas==2.0.3`).  
- **Range Specifier**: Allow version range (`pandas>=2.0,<3.0`).  
- **Reproducible Build**: Same inputs produce identical outputs across machines/time.  
- **Container Registry**: Storage for Docker images (Docker Hub, GHCR, ECR).

## Commands

**1. Create Python environment with uv**

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create virtual environment
uv venv --python 3.11

# Activate
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate    # Windows
```

**2. Install dependencies**

```bash
# Install from pyproject.toml
uv pip install -e ".[dev]"

# Add new dependency
uv pip install pandas scikit-learn

# Generate lock file
uv pip freeze > requirements.lock
```

**3. Setup pre-commit hooks**

```bash
# Install pre-commit
uv pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
        args: ['--maxkb=1000']

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.6
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
EOF

# Install hooks
pre-commit install

# Run manually on all files
pre-commit run --all-files
```

**4. Create Dockerfile (multi-stage)**

```bash
cat > Dockerfile << 'EOF'
# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /build

# Install uv
RUN pip install --no-cache-dir uv

# Copy dependency files
COPY pyproject.toml ./

# Install dependencies to /install
RUN uv venv /install && \
    /install/bin/pip install .

# Stage 2: Runtime
FROM python:3.11-slim

# Create non-root user
RUN useradd -m -u 1000 mlops

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /install

# Copy application code
COPY src/ ./src/

# Set PATH to use venv
ENV PATH="/install/bin:$PATH"

# Switch to non-root user
USER mlops

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "print('healthy')"

CMD ["python", "-m", "src.serving.main"]
EOF
```

**5. Build Docker image**

```bash
docker build -t ${REGISTRY}/${MODEL_NAME}:latest .
```

**6. Test container locally**

```bash
docker run --rm -p 8000:8000 ${REGISTRY}/${MODEL_NAME}:latest
```

**7. Create .dockerignore**

```bash
cat > .dockerignore << 'EOF'
.venv
venv
__pycache__
*.pyc
.git
.github
.pytest_cache
.ruff_cache
data/
notebooks/
tests/
*.md
.env
EOF
```

### Verify

```bash
# Check Python version
python --version
# Expected: Python 3.11.x

# Verify packages installed
uv pip list | grep -E "mlflow|pandas|fastapi"
# Expected: all present

# Test pre-commit
echo "test  " > test.txt  # trailing whitespace
pre-commit run --files test.txt
# Expected: fixes whitespace

# Verify Docker image
docker images | grep ${MODEL_NAME}
# Expected: image listed with size ~200MB (slim)

# Check for vulnerabilities (requires trivy)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ${REGISTRY}/${MODEL_NAME}:latest
```

### Notes

- Use `uv` for faster dependency resolution than pip.  
- Lock files ensure reproducibility; regenerate after adding packages.  
- Multi-stage builds reduce image size by excluding build tools from runtime.  
- Pre-commit hooks prevent bad commits (secrets, large files, formatting).

### Mini-Lab (10 min)

**Objective**: Set up environment and validate with tests.

1. Create test file:
   ```bash
   mkdir -p tests
   cat > tests/test_imports.py << 'EOF'
   def test_imports():
       import pandas
       import sklearn
       import mlflow
       assert True
   EOF
   ```

2. Run tests:
   ```bash
   pytest tests/
   # Expected: 1 passed
   ```

3. Create sample script with bad formatting:
   ```bash
   cat > src/test_fmt.py << 'EOF'
   def bad_format(  x,y  ):
       return x+y
   EOF
   ```

4. Run pre-commit:
   ```bash
   pre-commit run --files src/test_fmt.py
   # Expected: ruff-format fixes spacing
   ```

5. Build Docker image:
   ```bash
   docker build -t test-app:latest .
   # Expected: successful build
   ```

**Expected outcome**: Tests pass, formatting fixed, image built.

### Quiz (5 Questions)

1. What is a lock file?  
   → Exact pinned versions of all dependencies for reproducibility.

2. Why use multi-stage Docker builds?  
   → Smaller final images; build tools not included in runtime.

3. What does pre-commit do?  
   → Runs checks (formatting, linting, secrets) before allowing commit.

4. What's the difference between `pip install` and `pip install -e .`?  
   → `-e` is editable mode; changes reflect without reinstall.

5. Why create a non-root user in Docker?  
   → Security best practice; limits damage if container compromised.

### Common Mistakes

- Not activating virtual environment → installing to system Python.  
- Forgetting to regenerate lock file after adding packages → non-reproducible builds.  
- Large Docker images (>1GB) → use slim base images, multi-stage builds.  
- Committing `.env` files with secrets → use `.gitignore` + pre-commit gitleaks hook.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- Dependency conflicts → check `uv pip tree`, isolate conflicting packages.  
- Docker build fails on pip install → check network, use `--no-cache-dir`.  
- Pre-commit hook fails → run `pre-commit run --all-files` to debug.

---

# CHAPTER 3: DATA VERSIONING & QUALITY

## Definitions

- **DVC**: Data Version Control—Git for data files.  
- **Remote Storage**: External storage for DVC (S3, GCS, Azure Blob, SSH).  
- **DVC Cache**: Local copy of tracked files for fast access.  
- **DVC Pipeline**: Declarative workflow defining data/model dependencies.  
- **Checksum**: Hash of file content; DVC uses MD5 by default.  
- **Data Validation**: Checking schema, types, ranges, distributions.  
- **Schema Drift**: Changes in data structure (e.g., missing column, type change).  
- **Data Quality**: Completeness, accuracy, consistency, timeliness.  
- **Great Expectations**: Library for data testing and validation.  
- **Evidently**: Library for data drift detection and model monitoring.  
- **Outlier**: Data point significantly different from others; may indicate error or interesting case.  
- **Missing Data**: Null/NaN values; handle via imputation or removal.  
- **Data Lineage**: Tracking origin and transformations applied to data.  
- **Data Catalog**: Inventory of available datasets with metadata.  
- **Data Snapshot**: Point-in-time copy of dataset; DVC tags enable this.

## Commands

**1. Install DVC**

```bash
uv pip install dvc[s3]
# For other backends: dvc[gs] (GCS), dvc[azure] (Azure), dvc[ssh] (SSH)
```

**2. Initialize DVC**

```bash
cd mlops-project
dvc init
git add .dvc .dvcignore
git commit -m "feat: initialize DVC"
```

**3. Configure remote storage (MinIO local)**

```bash
# Using local MinIO from Chapter 0
dvc remote add -d minio s3://mlops-artifacts
dvc remote modify minio endpointurl http://localhost:9000
dvc remote modify minio access_key_id minioadmin
dvc remote modify minio secret_access_key minioadmin

git add .dvc/config
git commit -m "feat: add DVC remote"
```

**4. Track dataset with DVC**

```bash
# Generate sample dataset
python << EOF
import pandas as pd
import numpy as np

np.random.seed(42)
df = pd.DataFrame({
    'user_id': range(1000),
    'feature1': np.random.rand(1000),
    'feature2': np.random.rand(1000),
    'label': np.random.randint(0, 2, 1000)
})
df.to_csv('data/raw/dataset.csv', index=False)
EOF

# Track with DVC
dvc add data/raw/dataset.csv

# Commit DVC metadata
git add data/raw/dataset.csv.dvc data/raw/.gitignore
git commit -m "data: add initial dataset"
```

**5. Push data to remote**

```bash
dvc push
```

**6. Pull data (simulate new clone)**

```bash
# On another machine or fresh clone:
# git clone <repo>
# dvc pull

# For this demo:
rm data/raw/dataset.csv
dvc pull
# Expected: file restored
```

**7. Create data pipeline (dvc.yaml)**

```bash
cat > dvc.yaml << 'EOF'
stages:
  prepare:
    cmd: python src/data/prepare.py
    deps:
      - data/raw/dataset.csv
    outs:
      - data/processed/train.csv
      - data/processed/test.csv
EOF
```

**8. Validate data with Evidently**

```bash
uv pip install evidently

# Create validation script
cat > src/data/validate.py << 'EOF'
import pandas as pd
from evidently.report import Report
from evidently.metric_preset import DataQualityPreset

df = pd.read_csv('data/raw/dataset.csv')

report = Report(metrics=[DataQualityPreset()])
report.run(reference_data=None, current_data=df)
report.save_html('reports/data_quality.html')
print("✓ Data quality report saved")
EOF

mkdir -p reports
python src/data/validate.py
```

**9. Check for schema changes**

```bash
# Save schema
python << EOF
import pandas as pd
df = pd.read_csv('data/raw/dataset.csv')
schema = df.dtypes.to_dict()
print(schema)
EOF
```

### Verify

```bash
# Check DVC tracking
dvc status
# Expected: up to date

# Verify remote push
dvc remote list
# Expected: minio s3://mlops-artifacts

# Check DVC cache
du -sh .dvc/cache
# Expected: size matching tracked files

# Validate data
ls reports/
# Expected: data_quality.html
```

### Notes

- DVC stores metadata (.dvc files) in Git; actual data in remote storage.  
- Use `dvc repro` to run pipelines; automatically detects changed dependencies.  
- Evidently generates HTML reports; integrate into CI for continuous validation.  
- Never commit large data files to Git; always use DVC or similar tool.

### Mini-Lab (10 min)

**Objective**: Version dataset, modify it, and track changes.

1. Check initial dataset:
   ```bash
   wc -l data/raw/dataset.csv
   # Expected: 1001 (1000 rows + header)
   ```

2. Modify dataset (add 100 rows):
   ```bash
   python << EOF
   import pandas as pd
   df = pd.read_csv('data/raw/dataset.csv')
   new_rows = pd.DataFrame({
       'user_id': range(1000, 1100),
       'feature1': [0.5]*100,
       'feature2': [0.5]*100,
       'label': [1]*100
   })
   df = pd.concat([df, new_rows], ignore_index=True)
   df.to_csv('data/raw/dataset.csv', index=False)
   EOF
   ```

3. Check DVC status:
   ```bash
   dvc status
   # Expected: data/raw/dataset.csv modified
   ```

4. Update DVC tracking:
   ```bash
   dvc add data/raw/dataset.csv
   git add data/raw/dataset.csv.dvc
   git commit -m "data: add 100 more samples"
   dvc push
   ```

5. Verify new version:
   ```bash
   wc -l data/raw/dataset.csv
   # Expected: 1101
   ```

**Expected outcome**: Dataset versioned; can rollback via Git history of `.dvc` file.

### Quiz (5 Questions)

1. What does DVC track?  
   → Large data files; stores metadata in Git, data in remote storage.

2. How do you revert to previous dataset version?  
   → `git checkout <commit> data/raw/dataset.csv.dvc && dvc checkout`

3. What is schema drift?  
   → Changes in data structure (column added/removed, type changed).

4. Why validate data before training?  
   → Catch errors early; bad data = bad model (garbage in, garbage out).

5. What's the difference between DVC and Git LFS?  
   → DVC supports pipelines and ML workflows; Git LFS is simpler file storage.

### Common Mistakes

- Committing large files to Git instead of DVC → repo bloat, slow clones.  
- Forgetting to `dvc push` after `dvc add` → data not backed up.  
- Not setting up remote storage → DVC only local (no collaboration).  
- Ignoring schema validation → training fails on bad data.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- `dvc pull` fails with S3 error → check credentials, endpoint URL.  
- DVC cache full → `dvc gc` to clean unused files.  
- Pipeline doesn't detect changes → check deps/outs in `dvc.yaml`.

---

# CHAPTER 4: EXPERIMENT TRACKING

## Definitions

- **Experiment**: Single training run with specific hyperparameters, logged for comparison.  
- **Run**: MLflow term for one experiment execution.  
- **Parameter**: Input to training (learning_rate, batch_size, epochs).  
- **Metric**: Output measurement (accuracy, loss, F1-score).  
- **Artifact**: File logged to run (model, plot, dataset sample).  
- **Tag**: Label for organizing runs (e.g., `team=ml-eng`, `priority=high`).  
- **Parent Run**: Top-level run; can have nested child runs.  
- **Child Run**: Sub-run within a parent (e.g., cross-validation fold).  
- **Experiment Name**: Grouping for related runs.  
- **Tracking Server**: MLflow server storing all runs (backend DB + artifact store).  
- **Autologging**: Automatic parameter/metric logging for supported frameworks.  
- **Signature**: MLflow model signature defining input/output schema.  
- **Flavor**: Model format (sklearn, tensorflow, pytorch, onnx).  
- **Model URI**: Reference to logged model (`runs:/<run_id>/model`).  
- **Run Comparison**: Side-by-side analysis of multiple runs in MLflow UI.

## Commands

**1. Install MLflow**

```bash
uv pip install mlflow
```

**2. Set tracking server**

```bash
export MLFLOW_TRACKING_URI="http://localhost:5000"
export MLFLOW_S3_ENDPOINT_URL="http://localhost:9000"
export AWS_ACCESS_KEY_ID="minioadmin"
export AWS_SECRET_ACCESS_KEY="minioadmin"
```

**3. Log simple experiment**

```bash
cat > train_simple.py << 'EOF'
import mlflow
from sklearn.datasets import load_iris
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

# Load data
X, y = load_iris(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Set experiment
mlflow.set_experiment("iris-classification")

# Start run
with mlflow.start_run():
    # Log parameters
    max_depth = 3
    mlflow.log_param("max_depth", max_depth)
    mlflow.log_param("algorithm", "DecisionTree")
    
    # Train
    model = DecisionTreeClassifier(max_depth=max_depth, random_state=42)
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    # Log metrics
    mlflow.log_metric("accuracy", accuracy)
    
    # Log model
    mlflow.sklearn.log_model(model, "model")
    
    print(f"✓ Logged run with accuracy={accuracy:.3f}")
EOF

python train_simple.py
```

**4. Log artifacts (plots)**

```bash
cat > train_with_plot.py << 'EOF'
import mlflow
from sklearn.datasets import load_iris
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix, ConfusionMatrixDisplay
import matplotlib.pyplot as plt

X, y = load_iris(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

mlflow.set_experiment("iris-classification")

with mlflow.start_run():
    model = DecisionTreeClassifier(max_depth=3, random_state=42)
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    # Create confusion matrix plot
    cm = confusion_matrix(y_test, y_pred)
    disp = ConfusionMatrixDisplay(confusion_matrix=cm)
    disp.plot()
    plt.savefig("confusion_matrix.png")
    
    # Log
    mlflow.log_param("max_depth", 3)
    mlflow.log_metric("accuracy", accuracy)
    mlflow.log_artifact("confusion_matrix.png")
    mlflow.sklearn.log_model(model, "model")
    
    print("✓ Logged run with confusion matrix")
EOF

python train_with_plot.py
```

**5. Autologging (minimal code)**

```bash
cat > train_autolog.py << 'EOF'
import mlflow
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

# Enable autologging
mlflow.sklearn.autolog()

X, y = load_iris(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

mlflow.set_experiment("iris-classification")

with mlflow.start_run():
    model = RandomForestClassifier(n_estimators=10, max_depth=3, random_state=42)
    model.fit(X_train, y_train)
    score = model.score(X_test, y_test)
    print(f"✓ Autologged run with score={score:.3f}")
EOF

python train_autolog.py
```

**6. Search runs**

```bash
# Using Python API
python << EOF
import mlflow
client = mlflow.MlflowClient()
runs = client.search_runs(
    experiment_ids=["1"],
    order_by=["metrics.accuracy DESC"],
    max_results=5
)
for run in runs:
    print(f"Run {run.info.run_id}: accuracy={run.data.metrics.get('accuracy', 'N/A')}")
EOF

# Or via CLI
mlflow runs list --experiment-id 1
```

**7. Load logged model**

```bash
cat > load_model.py << 'EOF'
import mlflow

# Get best run
client = mlflow.MlflowClient()
runs = client.search_runs(
    experiment_ids=["1"],
    order_by=["metrics.accuracy DESC"],
    max_results=1
)
best_run_id = runs[0].info.run_id

# Load model
model_uri = f"runs:/{best_run_id}/model"
model = mlflow.sklearn.load_model(model_uri)

# Predict
import numpy as np
sample = np.array([[5.1, 3.5, 1.4, 0.2]])  # Iris setosa
prediction = model.predict(sample)
print(f"Prediction: {prediction}")
EOF

python load_model.py
```

### Verify

```bash
# Check MLflow UI
# Open http://localhost:5000
# Expected: See "iris-classification" experiment with multiple runs

# List experiments
mlflow experiments list
# Expected: iris-classification with ID

# Check artifacts in MinIO
# Open http://localhost:9001
# Expected: mlflow-artifacts bucket with run folders
```

### Notes

- MLflow tracks params, metrics, artifacts, and models in a unified interface.  
- Autologging reduces boilerplate; automatically logs framework-specific details.  
- Models are versioned and can be loaded via URI (`runs:/`, `models:/`).  
- Always set experiment name to group related runs.

### Mini-Lab (10 min)

**Objective**: Run hyperparameter sweep and find best model.

1. Create sweep script:
   ```bash
   cat > hyperparam_sweep.py << 'EOF'
   import mlflow
   from sklearn.datasets import load_iris
   from sklearn.tree import DecisionTreeClassifier
   from sklearn.model_selection import train_test_split
   from sklearn.metrics import accuracy_score
   
   X, y = load_iris(return_X_y=True)
   X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
   
   mlflow.set_experiment("iris-classification")
   
   for depth in [2, 3, 5, 10]:
       with mlflow.start_run():
           mlflow.log_param("max_depth", depth)
           model = DecisionTreeClassifier(max_depth=depth, random_state=42)
           model.fit(X_train, y_train)
           accuracy = accuracy_score(y_test, model.predict(X_test))
           mlflow.log_metric("accuracy", accuracy)
           print(f"Depth {depth}: accuracy={accuracy:.3f}")
   EOF
   ```

2. Run sweep:
   ```bash
   python hyperparam_sweep.py
   ```

3. Open MLflow UI, sort by accuracy descending, identify best depth.

**Expected outcome**: 4 runs logged; best accuracy at depth=3 or 5.

### Quiz (5 Questions)

1. What does MLflow track?  
   → Parameters, metrics, artifacts, models, tags, code version.

2. What's the difference between a parameter and a metric?  
   → Parameter=input (learning_rate); Metric=output (accuracy).

3. Why use autologging?  
   → Less code; framework automatically logs params/metrics/model.

4. How do you load a logged model?  
   → `mlflow.<flavor>.load_model("runs:/<run_id>/model")`

5. What is a parent/child run structure for?  
   → Nested runs (e.g., hyperparameter tuning, cross-validation folds).

### Common Mistakes

- Not setting experiment name → all runs in "Default" experiment.  
- Forgetting to log model → can't deploy later.  
- Logging too many artifacts → storage bloat; log only essential files.  
- Hardcoding tracking URI in code → use env var `MLFLOW_TRACKING_URI`.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- MLflow UI shows no runs → check tracking URI, experiment ID.  
- Artifacts not appearing → verify S3 endpoint, credentials.  
- Run comparison slow → too many runs; filter by date/tags.

---

# CHAPTER 5: FEATURE STORE (OPTIONAL)

## Definitions

- **Feature Store**: Centralized repository for storing, managing, and serving features.  
- **Feature**: Transformed input variable for ML (e.g., `user_age_bucket`, `purchase_count_7d`).  
- **Feature View**: Logical grouping of features for a model.  
- **Online Store**: Low-latency database for real-time feature serving (Redis, DynamoDB).  
- **Offline Store**: Batch storage for training (S3, Hive, BigQuery).  
- **Feature Engineering**: Transforming raw data into features (aggregations, encodings).  
- **Feature Reusability**: Share features across teams/models to avoid duplication.  
- **Point-in-Time Correctness**: Ensure training uses only data available at that time (no data leakage).  
- **Feature Freshness**: How recently a feature was computed.  
- **Feature Drift**: Change in feature distribution over time.  
- **Entity**: Primary key for features (e.g., `user_id`, `product_id`).  
- **Event Timestamp**: When feature value was valid.  
- **Feature Service**: API endpoint serving features to models.  
- **Materialization**: Computing and storing features ahead of time.  
- **Backfill**: Historical feature computation for training datasets.

## Commands (Using Feast as Example)

**1. Install Feast**

```bash
uv pip install feast
```

**2. Initialize Feast repo**

```bash
feast init feast_repo
cd feast_repo
```

**3. Define feature view (feature_store.py)**

```bash
cat > feature_store.py << 'EOF'
from datetime import timedelta
from feast import Entity, FeatureView, Field, FileSource
from feast.types import Float32, Int64

# Define entity
user = Entity(name="user_id", join_keys=["user_id"])

# Define source
user_features_source = FileSource(
    path="../data/processed/user_features.parquet",
    timestamp_field="event_timestamp",
)

# Define feature view
user_features = FeatureView(
    name="user_features",
    entities=[user],
    ttl=timedelta(days=1),
    schema=[
        Field(name="age", dtype=Int64),
        Field(name="purchase_count_7d", dtype=Int64),
        Field(name="avg_purchase_amount", dtype=Float32),
    ],
    source=user_features_source,
)
EOF
```

**4. Create sample feature data**

```bash
cd ..
python << EOF
import pandas as pd
from datetime import datetime, timedelta

df = pd.DataFrame({
    'user_id': [1, 2, 3, 4, 5],
    'age': [25, 35, 45, 30, 50],
    'purchase_count_7d': [3, 1, 5, 2, 0],
    'avg_purchase_amount': [50.0, 100.0, 75.0, 120.0, 0.0],
    'event_timestamp': [datetime.now() - timedelta(hours=i) for i in range(5)]
})
df.to_parquet('data/processed/user_features.parquet', index=False)
print("✓ Created sample feature data")
EOF
```

**5. Apply feature definitions**

```bash
cd feast_repo
feast apply
```

**6. Materialize features (offline → online)**

```bash
# For local testing (SQLite online store)
feast materialize-incremental $(date -u +"%Y-%m-%dT%H:%M:%S")
```

**7. Fetch features for online serving**

```bash
python << EOF
from feast import FeatureStore

store = FeatureStore(repo_path=".")
features = store.get_online_features(
    features=["user_features:age", "user_features:purchase_count_7d"],
    entity_rows=[{"user_id": 1}, {"user_id": 2}],
).to_dict()

print(features)
EOF
```

**8. Fetch historical features for training**

```bash
python << EOF
import pandas as pd
from feast import FeatureStore
from datetime import datetime

store = FeatureStore(repo_path=".")

entity_df = pd.DataFrame({
    'user_id': [1, 2, 3],
    'event_timestamp': [datetime.now()] * 3
})

training_df = store.get_historical_features(
    entity_df=entity_df,
    features=["user_features:age", "user_features:purchase_count_7d", "user_features:avg_purchase_amount"],
).to_df()

print(training_df)
EOF
```

### Verify

```bash
# List feature views
feast feature-views list
# Expected: user_features

# Check online store (SQLite)
ls feast_repo/data/
# Expected: online_store.db

# Validate feature serving
python -c "from feast import FeatureStore; store = FeatureStore(repo_path='feast_repo'); print('✓ Store loaded')"
```

### Notes

- Feature stores solve feature reusability and point-in-time correctness.  
- Offline store for training (batch); online store for inference (real-time).  
- Not always needed for small projects; adds complexity.  
- Alternatives: Tecton, Hopsworks, AWS SageMaker Feature Store.

### Mini-Lab (10 min)

**Objective**: Define, materialize, and serve features.

1. Follow commands above to set up Feast repo.

2. Add new feature:
   ```bash
   cd feast_repo
   # Edit feature_store.py to add `lifetime_value` field
   cat >> feature_store.py << 'EOF'
   
   # Update schema
   # Add: Field(name="lifetime_value", dtype=Float32)
   EOF
   ```

3. Update sample data:
   ```bash
   cd ..
   python << EOF
   import pandas as pd
   df = pd.read_parquet('data/processed/user_features.parquet')
   df['lifetime_value'] = [500.0, 1000.0, 750.0, 1200.0, 0.0]
   df.to_parquet('data/processed/user_features.parquet', index=False)
   EOF
   ```

4. Apply changes:
   ```bash
   cd feast_repo
   feast apply
   feast materialize-incremental $(date -u +"%Y-%m-%dT%H:%M:%S")
   ```

5. Fetch new feature:
   ```bash
   python << EOF
   from feast import FeatureStore
   store = FeatureStore(repo_path=".")
   features = store.get_online_features(
       features=["user_features:lifetime_value"],
       entity_rows=[{"user_id": 1}],
   ).to_dict()
   print(features)
   EOF
   ```

**Expected outcome**: Feature store serves new `lifetime_value` feature.

### Quiz (5 Questions)

1. What problem does a feature store solve?  
   → Feature reusability, point-in-time correctness, online/offline serving.

2. What's the difference between online and offline stores?  
   → Online=real-time (Redis); Offline=batch training (S3).

3. What is point-in-time correctness?  
   → Training uses only data available at that time (no leakage).

4. When should you NOT use a feature store?  
   → Small projects, simple features, single team (overhead not justified).

5. What is materialization?  
   → Computing and storing features from offline to online store.

### Common Mistakes

- Using feature store for simple projects → unnecessary complexity.  
- Not setting TTL → stale features served.  
- Forgetting to materialize → online store empty.  
- Schema mismatch between source and feature view → errors.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- `feast apply` fails → check YAML syntax, source paths.  
- Features not appearing online → run `feast materialize`.  
- Historical features slow → optimize offline store (partition, index).

---

# CHAPTER 6: TRAINING & EVALUATION

## Definitions

- **Training Loop**: Iterative process adjusting model weights to minimize loss.  
- **Loss Function**: Metric quantifying difference between predictions and actual values.  
- **Optimizer**: Algorithm updating weights (SGD, Adam, RMSProp).  
- **Hyperparameter**: Configuration not learned from data (learning_rate, batch_size).  
- **Epoch**: One complete pass through training dataset.  
- **Batch**: Subset of data used in one training step.  
- **Validation Set**: Data for tuning hyperparameters (not seen during training).  
- **Test Set**: Final evaluation data (never seen during development).  
- **Cross-Validation**: Split data into K folds; train K times, each fold as validation once.  
- **Overfitting**: Model memorizes training data; poor generalization.  
- **Underfitting**: Model too simple; can't capture patterns.  
- **Regularization**: Technique to prevent overfitting (L1, L2, dropout).  
- **Learning Rate**: Step size for weight updates; too high=unstable, too low=slow.  
- **Early Stopping**: Stop training when validation performance stops improving.  
- **Bias**: Error from incorrect assumptions (high bias=underfitting).  
- **Variance**: Error from sensitivity to training data (high variance=overfitting).

## Commands

**1. Create training script**

```bash
cat > src/models/train.py << 'EOF'
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import mlflow
import argparse

def train(n_estimators=100, max_depth=10, random_state=42):
    """Train a Random Forest classifier."""
    
    # Load data
    df = pd.read_csv('data/processed/train.csv')
    X = df.drop('label', axis=1)
    y = df['label']
    
    # Split
    X_train, X_val, y_train, y_val = train_test_split(
        X, y, test_size=0.2, random_state=random_state
    )
    
    # Train
    model = RandomForestClassifier(
        n_estimators=n_estimators,
        max_depth=max_depth,
        random_state=random_state,
        n_jobs=-1
    )
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_val)
    metrics = {
        'accuracy': accuracy_score(y_val, y_pred),
        'precision': precision_score(y_val, y_pred),
        'recall': recall_score(y_val, y_pred),
        'f1': f1_score(y_val, y_pred)
    }
    
    return model, metrics

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--n_estimators", type=int, default=100)
    parser.add_argument("--max_depth", type=int, default=10)
    args = parser.parse_args()
    
    mlflow.set_experiment("model-training")
    
    with mlflow.start_run():
        # Log params
        mlflow.log_param("n_estimators", args.n_estimators)
        mlflow.log_param("max_depth", args.max_depth)
        
        # Train
        model, metrics = train(args.n_estimators, args.max_depth)
        
        # Log metrics
        for key, value in metrics.items():
            mlflow.log_metric(key, value)
            print(f"{key}: {value:.3f}")
        
        # Log model
        mlflow.sklearn.log_model(model, "model")
EOF
```

**2. Create data preparation script**

```bash
cat > src/data/prepare.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

# Load raw data
df = pd.read_csv('data/raw/dataset.csv')

# Basic cleaning
df = df.dropna()

# Feature engineering (example)
df['feature_ratio'] = df['feature1'] / (df['feature2'] + 1e-8)

# Split
train, test = train_test_split(df, test_size=0.2, random_state=42)

# Save
train.to_csv('data/processed/train.csv', index=False)
test.to_csv('data/processed/test.csv', index=False)

print(f"✓ Train: {len(train)}, Test: {len(test)}")
EOF
```

**3. Run data preparation**

```bash
python src/data/prepare.py
```

**4. Train model**

```bash
python src/models/train.py --n_estimators 50 --max_depth 5
```

**5. Cross-validation script**

```bash
cat > src/models/cross_validate.py << 'EOF'
import pandas as pd
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import RandomForestClassifier
import numpy as np

df = pd.read_csv('data/processed/train.csv')
X = df.drop('label', axis=1)
y = df['label']

model = RandomForestClassifier(n_estimators=50, max_depth=5, random_state=42)
scores = cross_val_score(model, X, y, cv=5, scoring='accuracy')

print(f"Cross-validation scores: {scores}")
print(f"Mean accuracy: {np.mean(scores):.3f} (+/- {np.std(scores):.3f})")
EOF

python src/models/cross_validate.py
```

**6. Hyperparameter tuning (grid search)**

```bash
cat > src/models/tune.py << 'EOF'
import pandas as pd
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import RandomForestClassifier
import mlflow

df = pd.read_csv('data/processed/train.csv')
X = df.drop('label', axis=1)
y = df['label']

param_grid = {
    'n_estimators': [50, 100, 200],
    'max_depth': [5, 10, 15],
}

model = RandomForestClassifier(random_state=42)
grid = GridSearchCV(model, param_grid, cv=3, scoring='accuracy', n_jobs=-1)
grid.fit(X, y)

print(f"Best params: {grid.best_params_}")
print(f"Best score: {grid.best_score_:.3f}")

# Log best model
mlflow.set_experiment("model-training")
with mlflow.start_run():
    mlflow.log_params(grid.best_params_)
    mlflow.log_metric("cv_accuracy", grid.best_score_)
    mlflow.sklearn.log_model(grid.best_estimator_, "model")
EOF

python src/models/tune.py
```

### Verify

```bash
# Check processed data
ls -lh data/processed/
# Expected: train.csv, test.csv

# Verify training run in MLflow
mlflow runs list --experiment-name "model-training"
# Expected: runs with metrics

# Check model artifact
# Open http://localhost:5000 → "model-training" → latest run → artifacts
```

### Notes

- Always split data before any preprocessing to avoid data leakage.  
- Use cross-validation for small datasets; single validation split for large datasets.  
- Grid search is exhaustive; consider random search for large parameter spaces.  
- Log all hyperparameters and metrics to MLflow for reproducibility.

### Mini-Lab (10 min)

**Objective**: Train model, evaluate on test set, compare metrics.

1. Train baseline model:
   ```bash
   python src/models/train.py --n_estimators 10 --max_depth 3
   ```

2. Train improved model:
   ```bash
   python src/models/train.py --n_estimators 100 --max_depth 10
   ```

3. Create evaluation script:
   ```bash
   cat > src/models/evaluate.py << 'EOF'
   import pandas as pd
   import mlflow
   from sklearn.metrics import accuracy_score
   
   # Load test data
   df = pd.read_csv('data/processed/test.csv')
   X_test = df.drop('label', axis=1)
   y_test = df['label']
   
   # Load best model from MLflow
   client = mlflow.MlflowClient()
   runs = client.search_runs(
       experiment_ids=["2"],  # model-training experiment
       order_by=["metrics.accuracy DESC"],
       max_results=1
   )
   best_run_id = runs[0].info.run_id
   model = mlflow.sklearn.load_model(f"runs:/{best_run_id}/model")
   
   # Evaluate
   y_pred = model.predict(X_test)
   test_accuracy = accuracy_score(y_test, y_pred)
   
   print(f"✓ Test accuracy: {test_accuracy:.3f}")
   EOF
   
   python src/models/evaluate.py
   ```

**Expected outcome**: Improved model has higher validation accuracy; test accuracy close to validation.

### Quiz (5 Questions)

1. What's the difference between validation and test sets?  
   → Validation=tune hyperparameters; Test=final evaluation (never touch during development).

2. What is cross-validation?  
   → Split data into K folds; train K times, each fold as validation once; average results.

3. Why log hyperparameters?  
   → Reproducibility; know exactly what config produced each result.

4. What is overfitting?  
   → Model memorizes training data; poor performance on new data.

5. How do you detect overfitting?  
   → Training accuracy high, validation accuracy low (large gap).

### Common Mistakes

- Using test set during development → inflated performance estimates.  
- Not scaling features for distance-based models (KNN, SVM) → poor performance.  
- Forgetting to set `random_state` → non-reproducible results.  
- Grid searching too many parameters → combinatorial explosion (days to run).

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- Training too slow → reduce data size, use fewer estimators, parallelize.  
- OOM errors → batch processing, reduce model size, increase RAM.  
- Poor metrics → check data quality, try different models, feature engineering.

---

# CHAPTER 7: PIPELINES & ORCHESTRATION

## Definitions

- **Pipeline**: Automated workflow with sequential or parallel steps.  
- **DAG**: Directed Acyclic Graph—workflow where tasks have dependencies but no cycles.  
- **Task/Step**: Single unit of work (e.g., download data, train model).  
- **Dependency**: Task B depends on Task A (A must finish first).  
- **Orchestrator**: Tool managing pipeline execution (Airflow, Kubeflow, Prefect).  
- **Scheduler**: Triggers pipelines on a schedule (cron-like).  
- **Trigger**: Event starting a pipeline (time, file arrival, manual).  
- **Retry**: Re-run failed task automatically.  
- **Idempotent**: Task produces same result when run multiple times with same input.  
- **Sensor**: Task waiting for external condition (file exists, API ready).  
- **Operator**: Airflow task template (BashOperator, PythonOperator, KubernetesPodOperator).  
- **XCom**: Cross-communication—share data between Airflow tasks.  
- **Backfill**: Run pipeline for past dates.  
- **Dynamic Task**: Task generated at runtime based on data.  
- **Task Group**: Logical grouping of related tasks in Airflow UI.

## Commands (Using Airflow)

**1. Create Airflow DAG**

```bash
cat > dags/training_pipeline.py << 'EOF'
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

default_args = {
    'owner': 'mlops',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'training_pipeline',
    default_args=default_args,
    description='ML training pipeline',
    schedule_interval='@daily',
    catchup=False,
    tags=['ml', 'training'],
)

# Task 1: Prepare data
prepare = BashOperator(
    task_id='prepare_data',
    bash_command='cd /opt/airflow && python src/data/prepare.py',
    dag=dag,
)

# Task 2: Train model
train = BashOperator(
    task_id='train_model',
    bash_command='cd /opt/airflow && python src/models/train.py --n_estimators 100',
    dag=dag,
)

# Task 3: Evaluate
evaluate = BashOperator(
    task_id='evaluate_model',
    bash_command='cd /opt/airflow && python src/models/evaluate.py',
    dag=dag,
)

# Define dependencies
prepare >> train >> evaluate
EOF
```

**2. Test DAG**

```bash
# List DAGs
docker exec airflow airflow dags list
# Expected: training_pipeline

# Test task
docker exec airflow airflow tasks test training_pipeline prepare_data 2024-01-01
```

**3. Trigger DAG manually**

```bash
docker exec airflow airflow dags trigger training_pipeline
```

**4. Check DAG status**

```bash
docker exec airflow airflow dags list-runs -d training_pipeline
```

**5. Create Kubeflow Pipeline (alternative)**

```bash
uv pip install kfp

cat > pipelines/kubeflow_pipeline.py << 'EOF'
from kfp import dsl, compiler

@dsl.component(
    base_image='python:3.11-slim',
    packages_to_install=['pandas', 'scikit-learn']
)
def prepare_data(output_path: dsl.OutputPath()):
    import pandas as pd
    df = pd.DataFrame({'a': [1, 2, 3], 'b': [4, 5, 6]})
    df.to_csv(output_path, index=False)
    print("✓ Data prepared")

@dsl.component(
    base_image='python:3.11-slim',
    packages_to_install=['pandas', 'scikit-learn']
)
def train_model(input_path: dsl.InputPath()):
    import pandas as pd
    df = pd.read_csv(input_path)
    print(f"✓ Training on {len(df)} samples")
    # Training logic here

@dsl.pipeline(name='Training Pipeline')
def training_pipeline():
    prepare_task = prepare_data()
    train_task = train_model(input_path=prepare_task.output)

# Compile
compiler.Compiler().compile(training_pipeline, 'pipeline.yaml')
print("✓ Pipeline compiled")
EOF

python pipelines/kubeflow_pipeline.py
```

**6. Create DVC pipeline (alternative)**

```bash
cat > dvc.yaml << 'EOF'
stages:
  prepare:
    cmd: python src/data/prepare.py
    deps:
      - src/data/prepare.py
      - data/raw/dataset.csv
    outs:
      - data/processed/train.csv
      - data/processed/test.csv

  train:
    cmd: python src/models/train.py
    deps:
      - src/models/train.py
      - data/processed/train.csv
    params:
      - train.n_estimators
      - train.max_depth
    metrics:
      - metrics.json:
          cache: false
    outs:
      - models/model.pkl
EOF

cat > params.yaml << 'EOF'
train:
  n_estimators: 100
  max_depth: 10
EOF

# Run pipeline
dvc repro
```

### Verify

```bash
# Airflow: Check UI
# Open http://localhost:8080 → DAGs → training_pipeline
# Expected: DAG visible, can trigger runs

# DVC: Check pipeline status
dvc dag
# Expected: ASCII diagram of stages

# Kubeflow: Check compiled YAML
cat pipeline.yaml
# Expected: K8s workflow YAML
```

### Notes

- Airflow good for scheduled batch pipelines; Kubeflow for Kubernetes-native.  
- DVC pipelines are lightweight; track with Git; no server needed.  
- Always make tasks idempotent (safe to re-run).  
- Use retries for transient failures (network errors).

### Mini-Lab (10 min)

**Objective**: Build and run a 3-step pipeline.

1. Create simplified DAG:
   ```bash
   cat > dags/simple_pipeline.py << 'EOF'
   from airflow import DAG
   from airflow.operators.bash import BashOperator
   from datetime import datetime
   
   dag = DAG('simple_pipeline', start_date=datetime(2024, 1, 1), schedule_interval=None, catchup=False)
   
   t1 = BashOperator(task_id='step1', bash_command='echo "Step 1 done"', dag=dag)
   t2 = BashOperator(task_id='step2', bash_command='echo "Step 2 done"', dag=dag)
   t3 = BashOperator(task_id='step3', bash_command='echo "Step 3 done"', dag=dag)
   
   t1 >> t2 >> t3
   EOF
   ```

2. Trigger pipeline:
   ```bash
   docker exec airflow airflow dags trigger simple_pipeline
   ```

3. Check logs:
   ```bash
   docker exec airflow airflow tasks logs simple_pipeline step1 $(date +%Y-%m-%d)
   ```

**Expected outcome**: All 3 tasks complete successfully in order.

### Quiz (5 Questions)

1. What is a DAG?  
   → Directed Acyclic Graph—workflow with task dependencies, no cycles.

2. Why make tasks idempotent?  
   → Safe to re-run; same result even if executed multiple times.

3. What's the difference between Airflow and Kubeflow?  
   → Airflow=general-purpose orchestrator; Kubeflow=ML-specific, Kubernetes-native.

4. What is XCom in Airflow?  
   → Cross-communication—pass small data between tasks.

5. What is backfill?  
   → Run pipeline for past dates to fill missing data.

### Common Mistakes

- Non-idempotent tasks → duplicate data or errors on retry.  
- Passing large data via XCom → use external storage (S3, DB).  
- Circular dependencies → DAG validation fails.  
- Not setting `catchup=False` → backfills all missed runs on deploy.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- DAG not appearing → check syntax errors in DAG file.  
- Tasks stuck in queue → increase worker count or resources.  
- Failed task keeps retrying → check logs, fix issue, clear task state.

---

# CHAPTER 8: MODEL REGISTRY & GOVERNANCE

## Definitions

- **Model Registry**: Central repository for versioned, approved models.  
- **Model Version**: Unique identifier for a specific trained model.  
- **Model Stage**: Lifecycle stage (None, Staging, Production, Archived).  
- **Model Alias**: Human-readable name for a model version (e.g., `champion`, `challenger`).  
- **Model Signature**: Input/output schema for model inference.  
- **Model Card**: Document describing model purpose, performance, limitations, ethics.  
- **Model Lineage**: Tracking code, data, and hyperparameters that produced a model.  
- **Model Approval**: Manual or automated gate before promoting to production.  
- **Model Comparison**: Side-by-side analysis of model versions.  
- **Model Deprecation**: Marking old models as obsolete.  
- **Governance**: Policies ensuring models are compliant, auditable, and ethical.  
- **Audit Trail**: Log of all model changes and approvals.  
- **Model Metadata**: Tags, description, owner, creation date.  
- **Model Artifacts**: Files associated with model (weights, preprocessor, config).  
- **Model Serving Endpoint**: API exposing model for inference.

## Commands (Using MLflow Model Registry)

**1. Register model**

```bash
cat > register_model.py << 'EOF'
import mlflow
from mlflow.tracking import MlflowClient

client = MlflowClient()

# Get best run
runs = client.search_runs(
    experiment_ids=["2"],  # model-training experiment
    order_by=["metrics.accuracy DESC"],
    max_results=1
)
best_run_id = runs[0].info.run_id

# Register model
model_uri = f"runs:/{best_run_id}/model"
model_name = "churn-predictor"

result = mlflow.register_model(model_uri, model_name)
print(f"✓ Registered {model_name} version {result.version}")
EOF

python register_model.py
```

**2. Transition model stage**

```bash
cat > transition_model.py << 'EOF'
from mlflow.tracking import MlflowClient

client = MlflowClient()
model_name = "churn-predictor"

# Get latest version
versions = client.search_model_versions(f"name='{model_name}'")
latest_version = versions[0].version

# Transition to Staging
client.transition_model_version_stage(
    name=model_name,
    version=latest_version,
    stage="Staging"
)

print(f"✓ Model version {latest_version} → Staging")
EOF

python transition_model.py
```

**3. Promote to Production**

```bash
cat > promote_model.py << 'EOF'
from mlflow.tracking import MlflowClient

client = MlflowClient()
model_name = "churn-predictor"

# Get staging version
versions = client.get_latest_versions(model_name, stages=["Staging"])
staging_version = versions[0].version

# Transition to Production
client.transition_model_version_stage(
    name=model_name,
    version=staging_version,
    stage="Production",
    archive_existing_versions=True  # Archive old production versions
)

print(f"✓ Model version {staging_version} → Production")
EOF

python promote_model.py
```

**4. Add model description and tags**

```bash
cat > update_model_metadata.py << 'EOF'
from mlflow.tracking import MlflowClient

client = MlflowClient()
model_name = "churn-predictor"

# Update registered model description
client.update_registered_model(
    name=model_name,
    description="Binary classifier predicting customer churn. Trained on historical transaction data."
)

# Get latest version
versions = client.search_model_versions(f"name='{model_name}'")
latest_version = versions[0].version

# Add tags to version
client.set_model_version_tag(model_name, latest_version, "owner", "ml-team")
client.set_model_version_tag(model_name, latest_version, "framework", "sklearn")
client.set_model_version_tag(model_name, latest_version, "dataset", "v1.2")

print("✓ Metadata updated")
EOF

python update_model_metadata.py
```

**5. Create model card**

```bash
cat > model_card.md << 'EOF'
# Model Card: Churn Predictor

## Model Details
- **Model Name**: churn-predictor  
- **Version**: 1  
- **Framework**: scikit-learn RandomForestClassifier  
- **Owner**: ml-team  
- **Created**: 2024-01-15

## Intended Use
Predict customer churn probability for subscription service. Used by retention team to target at-risk customers.

## Training Data
- **Source**: CRM database (2022-2023)  
- **Size**: 100,000 customers  
- **Features**: 15 (demographics, usage patterns, support tickets)  
- **Split**: 80% train, 20% validation

## Performance
- **Accuracy**: 0.87  
- **Precision**: 0.85  
- **Recall**: 0.82  
- **F1-Score**: 0.83  
- **AUC-ROC**: 0.91

## Limitations
- Model trained on US customers; may not generalize globally.  
- Does not account for seasonal promotions.  
- Performance degrades if input features missing.

## Ethical Considerations
- Model should not be sole factor in customer decisions.  
- Regular monitoring for bias across demographic groups.  
- Predictions are probabilistic; not deterministic.

## Maintenance
- **Retraining**: Quarterly or when drift detected.  
- **Monitoring**: Daily metrics tracking (accuracy, drift, latency).  
- **Owner**: ml-team@company.com
EOF

# Upload as artifact to latest model version
python << PYEOF
from mlflow.tracking import MlflowClient
client = MlflowClient()
versions = client.search_model_versions("name='churn-predictor'")
latest = versions[0]
client.set_model_version_tag(
    "churn-predictor",
    latest.version,
    "model_card",
    "See model_card.md in repo"
)
PYEOF
```

**6. Load model by stage**

```bash
cat > load_production_model.py << 'EOF'
import mlflow

model_name = "churn-predictor"
stage = "Production"

model = mlflow.pyfunc.load_model(f"models:/{model_name}/{stage}")
print(f"✓ Loaded {model_name} from {stage}")

# Example prediction
import pandas as pd
sample = pd.DataFrame([[0.5, 0.3, 0.7]], columns=['feature1', 'feature2', 'feature_ratio'])
prediction = model.predict(sample)
print(f"Prediction: {prediction}")
EOF

python load_production_model.py
```

### Verify

```bash
# Check registered models
mlflow models list
# Expected: churn-predictor

# List versions
mlflow models list-versions --name churn-predictor
# Expected: versions with stages

# Verify in UI
# Open http://localhost:5000 → Models → churn-predictor
# Expected: versions, stages, metadata
```

### Notes

- Model registry separates experiment tracking from production deployment.  
- Use stages (Staging, Production) to manage model lifecycle.  
- Always create model cards for governance and documentation.  
- Archive old production models; never delete (audit trail).

### Mini-Lab (10 min)

**Objective**: Register, test, and promote a model.

1. Train and register:
   ```bash
   python src/models/train.py --n_estimators 100
   python register_model.py
   ```

2. Transition to Staging:
   ```bash
   python transition_model.py
   ```

3. Test staging model:
   ```bash
   cat > test_staging.py << 'EOF'
   import mlflow
   import pandas as pd
   
   model = mlflow.pyfunc.load_model("models:/churn-predictor/Staging")
   sample = pd.DataFrame([[0.5, 0.3, 0.7]], columns=['feature1', 'feature2', 'feature_ratio'])
   prediction = model.predict(sample)
   print(f"✓ Staging prediction: {prediction}")
   EOF
   
   python test_staging.py
   ```

4. Promote to Production:
   ```bash
   python promote_model.py
   ```

**Expected outcome**: Model available in Production stage; old version archived.

### Quiz (5 Questions)

1. What is a model registry?  
   → Central repository for versioned, approved models.

2. What are model stages?  
   → Lifecycle states: None, Staging, Production, Archived.

3. Why create a model card?  
   → Document purpose, performance, limitations, ethics for governance.

4. What happens when you promote a model to Production with `archive_existing_versions=True`?  
   → Old production versions are archived automatically.

5. How do you load a model from registry?  
   → `mlflow.pyfunc.load_model("models:/<name>/<stage>")`

### Common Mistakes

- Not archiving old production models → confusion about which version is live.  
- Skipping staging → deploy directly to production (risky).  
- No model card → poor documentation, compliance issues.  
- Deleting model versions → loss of audit trail.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- Model not appearing in registry → check registration command, experiment ID.  
- Cannot transition stage → version already in that stage or locked.  
- Load model fails → verify stage name, model name spelling.

---

# CHAPTER 9: CI/CD FOR ML

## Definitions

- **CI**: Continuous Integration—automated testing on every code commit.  
- **CD**: Continuous Deployment/Delivery—automated release to environments.  
- **Pipeline**: Automated workflow triggered by code push.  
- **Job**: Unit of work in CI/CD pipeline (build, test, deploy).  
- **Artifact**: File produced by pipeline (Docker image, model, report).  
- **Runner**: Machine executing CI/CD jobs (GitHub Actions runner, GitLab runner).  
- **Secret**: Encrypted credential stored in CI/CD platform.  
- **Environment**: Deployment target (dev, staging, prod).  
- **Approval Gate**: Manual step before promoting to production.  
- **Smoke Test**: Quick test verifying basic functionality after deployment.  
- **Rollback**: Revert to previous version after failed deployment.  
- **Blue-Green Deployment**: Run old and new versions; switch traffic instantly.  
- **Canary Deployment**: Roll out new version to small user subset first.  
- **Security Scan**: Check code/container for vulnerabilities (Trivy, Grype, Gitleaks).  
- **SBOM**: Software Bill of Materials—list of dependencies.

## Commands (Using GitHub Actions)

**1. Create basic CI workflow**

```bash
mkdir -p .github/workflows

cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install uv
          uv pip install --system -e ".[dev]"
      
      - name: Run linters
        run: |
          ruff check src/
          ruff format --check src/
      
      - name: Run tests
        run: pytest tests/ -v
EOF
```

**2. Add Docker build job**

```bash
cat > .github/workflows/build.yml << 'EOF'
name: Build

on:
  push:
    tags:
      - 'v*'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Log in to registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
EOF
```

**3. Add security scanning**

```bash
cat > .github/workflows/security.yml << 'EOF'
name: Security

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  secrets-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Gitleaks scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  
  container-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build image
        run: docker build -t test-image:latest .
      
      - name: Run Trivy scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: test-image:latest
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # Fail on vulnerabilities
      
      - name: Upload results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
  
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          path: .
          format: spdx-json
          output-file: sbom.spdx.json
      
      - name: Scan SBOM with Grype
        uses: anchore/scan-action@v3
        with:
          sbom: sbom.spdx.json
          fail-build: true
          severity-cutoff: high
EOF
```

**4. Add deployment workflow with approval**

```bash
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        type: choice
        options:
          - dev
          - staging
          - prod

jobs:
  deploy-dev:
    if: inputs.environment == 'dev'
    runs-on: ubuntu-latest
    environment: dev
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to dev
        run: |
          echo "Deploying to dev..."
          # kubectl apply -f infra/k8s/overlays/dev/
  
  deploy-staging:
    if: inputs.environment == 'staging'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to staging
        run: |
          echo "Deploying to staging..."
          # kubectl apply -f infra/k8s/overlays/staging/
  
  deploy-prod:
    if: inputs.environment == 'prod'
    runs-on: ubuntu-latest
    environment:
      name: prod
      url: https://api.prod.example.com
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to prod
        run: |
          echo "Deploying to prod..."
          # kubectl apply -f infra/k8s/overlays/prod/
      
      - name: Smoke test
        run: |
          sleep 10
          curl -f https://api.prod.example.com/health || exit 1
EOF
```

**5. Local testing with act**

```bash
# Install act (GitHub Actions locally)
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Test workflow
act push --workflows .github/workflows/ci.yml
```

### Verify

```bash
# Check workflow files
ls -la .github/workflows/
# Expected: ci.yml, build.yml, security.yml, deploy.yml

# Validate YAML syntax
cat .github/workflows/ci.yml | python -c "import yaml, sys; yaml.safe_load(sys.stdin)"
# Expected: no errors

# Test Docker build locally
docker build -t test:latest .
docker run --rm aquasec/trivy image test:latest
```

### Notes

- CI runs on every commit; CD runs on tags or manual trigger.  
- Always scan for secrets (Gitleaks) and vulnerabilities (Trivy/Grype).  
- Use approval gates for production deployments.  
- Generate SBOM for supply chain security compliance.

### Mini-Lab (10 min)

**Objective**: Set up CI pipeline and run locally.

1. Create test file:
   ```bash
   cat > tests/test_ci.py << 'EOF'
   def test_basic():
       assert 1 + 1 == 2
   EOF
   ```

2. Create minimal CI:
   ```bash
   cat > .github/workflows/test-ci.yml << 'EOF'
   name: Test CI
   on: [push]
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-python@v5
           with:
             python-version: '3.11'
         - run: pip install pytest
         - run: pytest tests/
   EOF
   ```

3. Test locally with act:
   ```bash
   act push --workflows .github/workflows/test-ci.yml
   ```

**Expected outcome**: CI job runs locally; test passes.

### Quiz (5 Questions)

1. What's the difference between CI and CD?  
   → CI=automated testing on commit; CD=automated deployment to environments.

2. What is an approval gate?  
   → Manual step requiring human approval before proceeding (e.g., prod deploy).

3. Why scan containers with Trivy?  
   → Detect vulnerabilities in dependencies, OS packages, images.

4. What is SBOM?  
   → Software Bill of Materials—list of all dependencies for security audits.

5. What is a smoke test?  
   → Quick test verifying basic functionality after deployment.

### Common Mistakes

- No security scanning → deploy vulnerable code.  
- Hardcoded secrets in workflows → use GitHub Secrets.  
- No approval gate for prod → accidental deployments.  
- CI too slow (>10min) → parallelize, cache dependencies.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- CI fails on `pip install` → cache dependencies, check network.  
- Docker build timeout → use layer caching, multi-stage builds.  
- Trivy fails with false positives → configure ignore list.

---

# CHAPTER 10: SERVING & INFERENCE

## Definitions

- **Model Serving**: Exposing trained model via API for predictions.  
- **Inference**: Using model to make predictions on new data.  
- **Batch Inference**: Process large dataset offline; write results to storage.  
- **Online Inference**: Real-time predictions per request (low latency).  
- **Endpoint**: API URL accepting requests and returning predictions.  
- **Request/Response Schema**: Input/output format for API (JSON, Protocol Buffers).  
- **Latency**: Time from request received to response returned (p50, p95, p99).  
- **Throughput**: Requests handled per second (RPS or QPS).  
- **Autoscaling**: Automatically adjust replicas based on load.  
- **Load Balancer**: Distribute requests across multiple model replicas.  
- **Health Check**: Endpoint verifying service is alive (`/health`).  
- **Readiness Check**: Endpoint verifying service is ready to serve (`/ready`).  
- **Model Preloading**: Load model at startup to avoid cold start.  
- **Cold Start**: Delay when model loaded on first request.  
- **GPU Inference**: Use GPU for faster predictions (large models).

## Commands

**1. Create FastAPI serving app**

```bash
cat > src/serving/main.py << 'EOF'
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import mlflow
import pandas as pd
import os

app = FastAPI(title="ML Model API")

# Load model at startup
model = None

@app.on_event("startup")
def load_model():
    global model
    model_uri = os.getenv("MODEL_URI", "models:/churn-predictor/Production")
    model = mlflow.pyfunc.load_model(model_uri)
    print(f"✓ Loaded model from {model_uri}")

class PredictionRequest(BaseModel):
    feature1: float
    feature2: float
    feature_ratio: float

class PredictionResponse(BaseModel):
    prediction: int
    probability: float
    model_version: str

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/ready")
def ready():
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    return {"status": "ready"}

@app.post("/predict", response_model=PredictionResponse)
def predict(request: PredictionRequest):
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    # Prepare input
    df = pd.DataFrame([request.dict()])
    
    # Predict
    prediction = int(model.predict(df)[0])
    probability = float(model.predict_proba(df)[0][prediction]) if hasattr(model, 'predict_proba') else 0.0
    
    return PredictionResponse(
        prediction=prediction,
        probability=probability,
        model_version="1.0"
    )

@app.get("/")
def root():
    return {"message": "ML Model API", "docs": "/docs"}
EOF
```

**2. Create requirements for serving**

```bash
cat > requirements-serve.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
mlflow==2.8.0
pandas==2.1.3
scikit-learn==1.3.2
EOF
```

**3. Run locally**

```bash
# Install dependencies
pip install -r requirements-serve.txt

# Start server
export MLFLOW_TRACKING_URI=http://localhost:5000
export MODEL_URI="models:/churn-predictor/Production"
uvicorn src.serving.main:app --host 0.0.0.0 --port 8000 --reload
```

**4. Test API**

```bash
# Health check
curl http://localhost:8000/health
# Expected: {"status":"healthy"}

# Readiness check
curl http://localhost:8000/ready
# Expected: {"status":"ready"}

# Prediction
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"feature1": 0.5, "feature2": 0.3, "feature_ratio": 0.7}'
# Expected: {"prediction":0,"probability":0.85,"model_version":"1.0"}
```

**5. Create Dockerfile for serving**

```bash
cat > Dockerfile.serve << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements-serve.txt .
RUN pip install --no-cache-dir -r requirements-serve.txt

# Copy application
COPY src/serving/ ./src/serving/

# Create non-root user
RUN useradd -m -u 1000 mlops && chown -R mlops:mlops /app
USER mlops

# Environment variables
ENV MLFLOW_TRACKING_URI=http://mlflow:5000
ENV MODEL_URI=models:/churn-predictor/Production

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# Start server
CMD ["uvicorn", "src.serving.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
```

**6. Build and run container**

```bash
docker build -f Dockerfile.serve -t model-api:latest .

docker run -d --name model-api \
  -p 8000:8000 \
  -e MLFLOW_TRACKING_URI=http://host.docker.internal:5000 \
  -e MODEL_URI="models:/churn-predictor/Production" \
  model-api:latest

# Test
curl http://localhost:8000/health
```

**7. Deploy to Kubernetes**

```bash
cat > infra/k8s/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: model-api
  template:
    metadata:
      labels:
        app: model-api
    spec:
      containers:
      - name: api
        image: ghcr.io/myorg/model-api:latest
        ports:
        - containerPort: 8000
        env:
        - name: MLFLOW_TRACKING_URI
          value: "http://mlflow:5000"
        - name: MODEL_URI
          value: "models:/churn-predictor/Production"
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: model-api
spec:
  selector:
    app: model-api
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: model-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: model-api
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF
```

**8. Deploy**

```bash
kubectl apply -f infra/k8s/base/deployment.yaml
kubectl get pods -l app=model-api
# Expected: 2 pods running
```

### Verify

```bash
# Test container
docker ps | grep model-api
# Expected: running

# Test API
curl http://localhost:8000/docs
# Expected: FastAPI Swagger UI

# Check latency
time curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"feature1": 0.5, "feature2": 0.3, "feature_ratio": 0.7}'
# Expected: <100ms

# Kubernetes: Check HPA
kubectl get hpa model-api-hpa
# Expected: current replicas, target CPU%
```

### Notes

- FastAPI provides automatic API docs (`/docs`) via Swagger.  
- Always use health and readiness checks for Kubernetes deployments.  
- Load model at startup to avoid cold start on first request.  
- HPA scales pods based on CPU/memory or custom metrics.

### Mini-Lab (10 min)

**Objective**: Deploy API, send predictions, measure latency.

1. Start API locally:
   ```bash
   export MLFLOW_TRACKING_URI=http://localhost:5000
   export MODEL_URI="models:/churn-predictor/Production"
   uvicorn src.serving.main:app --host 0.0.0.0 --port 8000 &
   sleep 5
   ```

2. Send 10 requests:
   ```bash
   for i in {1..10}; do
     curl -X POST http://localhost:8000/predict \
       -H "Content-Type: application/json" \
       -d '{"feature1": 0.5, "feature2": 0.3, "feature_ratio": 0.7}' &
   done
   wait
   ```

3. Check health:
   ```bash
   curl http://localhost:8000/health
   ```

4. Stop server:
   ```bash
   pkill -f uvicorn
   ```

**Expected outcome**: All 10 predictions succeed; latency <100ms each.

### Quiz (5 Questions)

1. What's the difference between batch and online inference?  
   → Batch=offline, large datasets; Online=real-time, per-request.

2. Why preload model at startup?  
   → Avoid cold start delay on first request.

3. What is HPA?  
   → Horizontal Pod Autoscaler—scales replicas based on metrics.

4. What's the difference between liveness and readiness probes?  
   → Liveness=is container alive? Readiness=is container ready to serve?

5. Why use FastAPI over Flask for ML?  
   → Faster (async), automatic docs, Pydantic validation, type hints.

### Common Mistakes

- Loading model on every request → high latency.  
- No health/readiness checks → Kubernetes routing to unhealthy pods.  
- No HPA → can't handle traffic spikes.  
- Returning raw numpy arrays → use Python types or Pydantic models.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- 503 errors → model not loaded; check logs, MLflow URI.  
- High latency → model too large, missing GPU, network slow.  
- HPA not scaling → metrics not available; check metrics-server.

---

# CHAPTER 11: OBSERVABILITY & MONITORING

## Definitions

- **Observability**: Ability to understand system state from external outputs (metrics, logs, traces).  
- **Monitoring**: Continuously collecting and analyzing metrics to detect issues.  
- **Metric**: Numerical measurement over time (latency, error rate, CPU).  
- **Log**: Text record of an event (request, error, warning).  
- **Trace**: Record of request path through distributed system.  
- **Dashboard**: Visual display of metrics (graphs, charts).  
- **Alert**: Notification when metric exceeds threshold.  
- **SLI**: Service Level Indicator—measurable metric (e.g., latency).  
- **SLO**: Service Level Objective—target for SLI (e.g., p95 latency <100ms).  
- **SLA**: Service Level Agreement—contract with consequences for SLO violations.  
- **Golden Signals**: Latency, Traffic, Errors, Saturation (Google SRE).  
- **Prometheus**: Time-series database for metrics.  
- **Grafana**: Visualization tool for metrics dashboards.  
- **Alertmanager**: Handles alerts from Prometheus (routing, grouping, silencing).  
- **Exporter**: Converts metrics to Prometheus format (node_exporter, custom).

## Commands

**1. Add Prometheus to docker-compose**

```bash
cat >> docker-compose.yml << 'EOF'

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    ports:
      - "9090:9090"
    volumes:
      - ./infra/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:9090"]
      interval: 10s
      timeout: 5s
      retries: 3

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./infra/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./infra/grafana/datasources:/etc/grafana/provisioning/datasources
    depends_on:
      - prometheus
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/api/health"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  prometheus_data:
  grafana_data:
EOF
```

**2. Create Prometheus config**

```bash
mkdir -p infra/prometheus

cat > infra/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'model-api'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['api:8000']

  - job_name: 'mlflow'
    static_configs:
      - targets: ['mlflow:5000']
EOF
```

**3. Add Prometheus metrics to FastAPI**

```bash
cat >> src/serving/main.py << 'EOF'

from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response
import time

# Metrics
REQUEST_COUNT = Counter('model_predictions_total', 'Total predictions', ['model', 'status'])
REQUEST_LATENCY = Histogram('model_prediction_latency_seconds', 'Prediction latency', ['model'])
PREDICTION_DISTRIBUTION = Counter('model_prediction_class', 'Prediction distribution', ['model', 'class'])

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/predict", response_model=PredictionResponse)
def predict(request: PredictionRequest):
    start_time = time.time()
    
    try:
        if model is None:
            REQUEST_COUNT.labels(model="churn-predictor", status="error").inc()
            raise HTTPException(status_code=503, detail="Model not loaded")
        
        df = pd.DataFrame([request.dict()])
        prediction = int(model.predict(df)[0])
        probability = float(model.predict_proba(df)[0][prediction]) if hasattr(model, 'predict_proba') else 0.0
        
        # Record metrics
        REQUEST_COUNT.labels(model="churn-predictor", status="success").inc()
        PREDICTION_DISTRIBUTION.labels(model="churn-predictor", class_=str(prediction)).inc()
        
        return PredictionResponse(
            prediction=prediction,
            probability=probability,
            model_version="1.0"
        )
    finally:
        REQUEST_LATENCY.labels(model="churn-predictor").observe(time.time() - start_time)
EOF
```

**4. Create Grafana datasource config**

```bash
mkdir -p infra/grafana/datasources

cat > infra/grafana/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
EOF
```

**5. Create Grafana dashboard**

```bash
mkdir -p infra/grafana/dashboards

cat > infra/grafana/dashboards/dashboard.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

cat > infra/grafana/dashboards/model-api.json << 'EOF'
{
  "dashboard": {
    "title": "Model API Metrics",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(model_predictions_total[5m])"
          }
        ],
        "type": "graph"
      },
      {
        "id": 2,
        "title": "p95 Latency",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(model_prediction_latency_seconds_bucket[5m]))"
          }
        ],
        "type": "graph"
      },
      {
        "id": 3,
        "title": "Prediction Distribution",
        "targets": [
          {
            "expr": "model_prediction_class"
          }
        ],
        "type": "piechart"
      }
    ]
  }
}
EOF
```

**6. Restart stack with monitoring**

```bash
docker compose down
docker compose up -d
```

**7. Check Prometheus targets**

```bash
# Open http://localhost:9090/targets
# Expected: All targets UP

# Query metrics
curl http://localhost:9090/api/v1/query?query=model_predictions_total
```

**8. Create alert rules**

```bash
cat > infra/prometheus/alerts.yml << 'EOF'
groups:
  - name: model_api
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(model_predictions_total{status="error"}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors/sec"

      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(model_prediction_latency_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "p95 latency is {{ $value }}s"

      - alert: ModelAPIDown
        expr: up{job="model-api"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Model API is down"
EOF

# Update prometheus.yml to include alerts
cat >> infra/prometheus/prometheus.yml << 'ALERTEOF'

rule_files:
  - 'alerts.yml'
ALERTEOF
```

### Verify

```bash
# Check Prometheus
curl http://localhost:9090/-/healthy
# Expected: Prometheus is Healthy.

# Check Grafana
curl http://localhost:3000/api/health
# Expected: {"commit":"...","database":"ok","version":"..."}

# Send test predictions to generate metrics
for i in {1..100}; do
  curl -X POST http://localhost:8000/predict \
    -H "Content-Type: application/json" \
    -d '{"feature1": 0.5, "feature2": 0.3, "feature_ratio": 0.7}' &
done
wait

# Query metrics
curl http://localhost:8000/metrics | grep model_predictions_total
```

### Notes

- Prometheus scrapes `/metrics` endpoints every 15s by default.  
- Grafana dashboards can be provisioned via JSON or created in UI.  
- Always monitor Golden Signals: Latency, Traffic, Errors, Saturation.  
- Set SLOs (e.g., p95 latency <100ms, error rate <1%) and alert on violations.

### Mini-Lab (10 min)

**Objective**: Set up monitoring, generate traffic, view metrics.

1. Start stack:
   ```bash
   docker compose up -d
   sleep 30  # Wait for services
   ```

2. Generate traffic:
   ```bash
   for i in {1..1000}; do
     curl -s -X POST http://localhost:8000/predict \
       -H "Content-Type: application/json" \
       -d '{"feature1": 0.5, "feature2": 0.3, "feature_ratio": 0.7}' > /dev/null &
   done
   wait
   ```

3. Open Grafana (http://localhost:3000), login (admin/admin), navigate to dashboards.

4. Query Prometheus (http://localhost:9090):
   ```
   rate(model_predictions_total[1m])
   ```

**Expected outcome**: See request rate, latency graphs in Grafana.

### Quiz (5 Questions)

1. What are the Golden Signals?  
   → Latency, Traffic, Errors, Saturation.

2. What's the difference between SLI, SLO, and SLA?  
   → SLI=metric; SLO=target; SLA=contract with penalties.

3. Why use histograms for latency?  
   → Calculate percentiles (p50, p95, p99) accurately.

4. What is Prometheus?  
   → Time-series database scraping and storing metrics.

5. What is Grafana?  
   → Visualization tool for creating metrics dashboards.

### Common Mistakes

- Not exposing `/metrics` endpoint → Prometheus can't scrape.  
- Alert on every error → alert fatigue; set thresholds.  
- Too many metrics → high cardinality, slow queries.  
- No SLOs defined → can't measure service health.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- Prometheus target DOWN → check network, firewall, endpoint.  
- No data in Grafana → verify datasource, query syntax.  
- Alerts not firing → check alert rules, evaluation interval.

---

# CHAPTER 12: DRIFT DETECTION & RETRAINING

## Definitions

- **Data Drift**: Statistical change in input feature distributions over time.  
- **Concept Drift**: Change in relationship between features and target (model degrades).  
- **Label Drift**: Change in target distribution.  
- **Covariate Shift**: Input distribution changes but P(Y|X) stays same.  
- **Prior Probability Shift**: Target distribution changes but P(X|Y) stays same.  
- **Drift Detection**: Monitoring for distribution changes.  
- **Statistical Test**: Method to detect drift (Kolmogorov-Smirnov, Chi-square).  
- **Baseline**: Reference distribution from training data.  
- **Window**: Time period for comparing distributions (sliding, tumbling).  
- **Retraining Trigger**: Condition causing automatic retraining (drift detected, schedule, performance drop).  
- **Retraining Pipeline**: Automated workflow to retrain model on new data.  
- **A/B Testing**: Compare new model against current production model.  
- **Shadow Mode**: Run new model alongside production; compare predictions without impacting users.  
- **Champion/Challenger**: Production model vs. new candidate model.  
- **Model Decay**: Gradual performance degradation over time.

## Commands (Using Evidently)

**1. Install Evidently**

```bash
uv pip install evidently
```

**2. Create drift detection script**

```bash
cat > src/monitoring/detect_drift.py << 'EOF'
import pandas as pd
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset, TargetDriftPreset
from evidently.test_suite import TestSuite
from evidently.test_preset import DataDriftTestPreset
import json

# Load reference (training) data
reference = pd.read_csv('data/processed/train.csv')

# Load current (production) data
# In production, fetch from logs or feature store
current = pd.read_csv('data/processed/current.csv')

# Create drift report
report = Report(metrics=[
    DataDriftPreset(),
    TargetDriftPreset()
])

report.run(reference_data=reference, current_data=current)
report.save_html('reports/drift_report.html')

# Create test suite (pass/fail)
test_suite = TestSuite(tests=[
    DataDriftTestPreset()
])

test_suite.run(reference_data=reference, current_data=current)
results = test_suite.as_dict()

# Check for drift
drift_detected = any(
    test['status'] == 'FAIL'
    for test in results['tests']
)

if drift_detected:
    print("⚠️  Drift detected! Triggering retraining...")
    with open('drift_alert.json', 'w') as f:
        json.dump({"drift_detected": True}, f)
    exit(1)
else:
    print("✓ No drift detected")
    exit(0)
EOF
```

**3. Create sample current data (with drift)**

```bash
python << EOF
import pandas as pd
import numpy as np

# Original distribution
np.random.seed(42)
df = pd.DataFrame({
    'user_id': range(1000, 1500),
    'feature1': np.random.rand(500) * 0.5 + 0.5,  # Shifted distribution
    'feature2': np.random.rand(500),
    'label': np.random.randint(0, 2, 500)
})
df['feature_ratio'] = df['feature1'] / (df['feature2'] + 1e-8)
df.to_csv('data/processed/current.csv', index=False)
print("✓ Created current data with drift")
EOF
```

**4. Run drift detection**

```bash
mkdir -p reports
python src/monitoring/detect_drift.py
```

**5. Create retraining pipeline (Airflow)**

```bash
cat > dags/retraining_pipeline.py << 'EOF'
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import BranchPythonOperator
from datetime import datetime, timedelta
import json
import os

default_args = {
    'owner': 'mlops',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
}

dag = DAG(
    'retraining_pipeline',
    default_args=default_args,
    description='Automated retraining on drift',
    schedule_interval='@daily',
    catchup=False,
)

def check_drift():
    """Check if drift detected."""
    if os.path.exists('/opt/airflow/drift_alert.json'):
        with open('/opt/airflow/drift_alert.json') as f:
            data = json.load(f)
        if data.get('drift_detected'):
            return 'retrain_model'
    return 'skip_retrain'

check = BranchPythonOperator(
    task_id='check_drift',
    python_callable=check_drift,
    dag=dag,
)

detect = BashOperator(
    task_id='detect_drift',
    bash_command='cd /opt/airflow && python src/monitoring/detect_drift.py',
    dag=dag,
)

retrain = BashOperator(
    task_id='retrain_model',
    bash_command='cd /opt/airflow && python src/models/train.py --n_estimators 100',
    dag=dag,
)

register = BashOperator(
    task_id='register_model',
    bash_command='cd /opt/airflow && python register_model.py',
    dag=dag,
)

skip = BashOperator(
    task_id='skip_retrain',
    bash_command='echo "No drift detected, skipping retrain"',
    dag=dag,
)

detect >> check >> [retrain, skip]
retrain >> register
EOF
```

**6. Schedule drift detection (cron)**

```bash
# Add to crontab (runs daily at 2 AM)
cat > scripts/check_drift.sh << 'EOF'
#!/bin/bash
cd /path/to/mlops-project
python src/monitoring/detect_drift.py

if [ $? -eq 1 ]; then
  echo "Drift detected, triggering Airflow DAG"
  docker exec airflow airflow dags trigger retraining_pipeline
fi
EOF

chmod +x scripts/check_drift.sh

# Add to crontab
# crontab -e
# 0 2 * * * /path/to/mlops-project/scripts/check_drift.sh
```

**7. Monitor drift metrics in Prometheus**

```bash
cat > src/monitoring/drift_exporter.py << 'EOF'
from prometheus_client import Gauge, start_http_server
import time
import json

# Metrics
DRIFT_SCORE = Gauge('model_drift_score', 'Drift score', ['feature'])

def export_drift_metrics():
    """Export drift metrics to Prometheus."""
    start_http_server(8001)
    
    while True:
        # Read drift results
        try:
            with open('reports/drift_results.json') as f:
                results = json.load(f)
            
            for feature, score in results.items():
                DRIFT_SCORE.labels(feature=feature).set(score)
        except Exception as e:
            print(f"Error: {e}")
        
        time.sleep(60)  # Update every minute

if __name__ == "__main__":
    export_drift_metrics()
EOF
```

### Verify

```bash
# Run drift detection
python src/monitoring/detect_drift.py
# Expected: Exit code 1 (drift detected)

# Check report
ls reports/
# Expected: drift_report.html

# Open report in browser
# Expected: See drift analysis with visualizations

# Check alert file
cat drift_alert.json
# Expected: {"drift_detected": true}
```

### Notes

- Evidently detects drift via statistical tests (KS test, Chi-square).  
- Run drift detection daily or weekly; more frequent = higher cost.  
- Always compare to baseline (training data).  
- Automatic retraining risky; include human review step.

### Mini-Lab (10 min)

**Objective**: Detect drift, trigger retraining.

1. Run drift detection:
   ```bash
   python src/monitoring/detect_drift.py
   ```

2. Check if drift detected:
   ```bash
   [ -f drift_alert.json ] && echo "Drift detected!" || echo "No drift"
   ```

3. If drift detected, retrain:
   ```bash
   python src/models/train.py --n_estimators 100
   python register_model.py
   ```

4. Open drift report:
   ```bash
   open reports/drift_report.html  # Mac
   # xdg-open reports/drift_report.html  # Linux
   ```

**Expected outcome**: Drift detected on `feature1`; model retrained and registered.

### Quiz (5 Questions)

1. What is data drift?  
   → Statistical change in input feature distributions over time.

2. What's the difference between data drift and concept drift?  
   → Data drift=features change; Concept drift=relationship between features and target changes.

3. Why is automatic retraining risky?  
   → May deploy bad model if data quality issues; needs human review.

4. What statistical tests detect drift?  
   → Kolmogorov-Smirnov (continuous), Chi-square (categorical).

5. What is shadow mode?  
   → Run new model alongside production; compare predictions without impacting users.

### Common Mistakes

- Not setting drift baseline → false positives.  
- Automatic retraining without validation → bad models in production.  
- Ignoring slow drift → gradual performance decay.  
- Not monitoring prediction distribution → miss label drift.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- False positive drift alerts → adjust test thresholds.  
- Retraining pipeline stuck → check dependencies, resources.  
- Drift report shows no drift but model failing → concept drift (not data drift).

---

# CHAPTER 13: SECURITY, PRIVACY & COST

## Definitions

- **Security**: Protecting systems from unauthorized access, attacks, and vulnerabilities.  
- **Secrets Management**: Securely storing credentials (API keys, passwords).  
- **IAM**: Identity and Access Management—who can do what.  
- **Least Privilege**: Grant minimum permissions needed.  
- **RBAC**: Role-Based Access Control—permissions based on roles.  
- **Encryption**: Convert data to unreadable format (at-rest, in-transit).  
- **PII**: Personally Identifiable Information—must be protected by law.  
- **GDPR**: General Data Protection Regulation—EU privacy law.  
- **Data Anonymization**: Remove identifying information from data.  
- **Audit Log**: Record of all access and changes for compliance.  
- **Vulnerability Scan**: Automated check for known security issues.  
- **SBOM**: Software Bill of Materials—list of dependencies.  
- **Zero Trust**: Never trust, always verify—authenticate every request.  
- **Cost Optimization**: Reduce cloud spend without sacrificing performance.  
- **Tagging**: Label resources for cost tracking and allocation.

## Commands

**1. Scan for secrets in code (Gitleaks)**

```bash
# Install Gitleaks
docker run -v $(pwd):/path zricethezav/gitleaks:latest detect --source /path --verbose

# Or install locally
brew install gitleaks  # Mac
# sudo apt install gitleaks  # Ubuntu

# Scan repo
gitleaks detect --source . --verbose
```

**2. Scan container for vulnerabilities (Trivy)**

```bash
# Install Trivy
brew install aquasecurity/trivy/trivy  # Mac
# sudo apt install trivy  # Ubuntu

# Scan image
trivy image model-api:latest

# Fail on HIGH/CRITICAL
trivy image --severity HIGH,CRITICAL --exit-code 1 model-api:latest
```

**3. Generate SBOM (Syft)**

```bash
# Install Syft
brew install syft  # Mac

# Generate SBOM
syft model-api:latest -o spdx-json > sbom.spdx.json

# Scan SBOM with Grype
grype sbom:./sbom.spdx.json
```

**4. Manage secrets with Kubernetes Secrets**

```bash
# Create secret
kubectl create secret generic mlflow-creds \
  --from-literal=username=mlops \
  --from-literal=password=secure-password

# Use in deployment
cat > infra/k8s/base/deployment-with-secrets.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-api
spec:
  template:
    spec:
      containers:
      - name: api
        image: model-api:latest
        env:
        - name: MLFLOW_USER
          valueFrom:
            secretKeyRef:
              name: mlflow-creds
              key: username
        - name: MLFLOW_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mlflow-creds
              key: password
EOF
```

**5. Use external secrets manager (AWS Secrets Manager example)**

```bash
# Install external-secrets operator
kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/crds/bundle.yaml
kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/external-secrets.yaml

# Create SecretStore
cat > infra/k8s/base/secret-store.yaml << 'EOF'
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
EOF

# Create ExternalSecret
cat > infra/k8s/base/external-secret.yaml << 'EOF'
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: mlflow-creds
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets
    kind: SecretStore
  target:
    name: mlflow-creds
    creationPolicy: Owner
  data:
  - secretKey: username
    remoteRef:
      key: mlflow-credentials
      property: username
  - secretKey: password
    remoteRef:
      key: mlflow-credentials
      property: password
EOF
```

**6. Enable pod security standards**

```bash
# Create PodSecurityPolicy (deprecated in K8s 1.25+)
# Use Pod Security Standards instead

cat > infra/k8s/base/pod-security.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: mlops
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
EOF

# Update deployment to comply
cat > infra/k8s/base/deployment-secure.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-api
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: api
        image: model-api:latest
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: tmp
        emptyDir: {}
EOF
```

**7. Cost tracking with tags**

```bash
# Terraform example: tag all resources
cat > infra/terraform/main.tf << 'EOF'
locals {
  common_tags = {
    Project     = "mlops-course"
    Environment = var.environment
    ManagedBy   = "terraform"
    CostCenter  = "ml-engineering"
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "mlops-artifacts-${var.environment}"
  
  tags = local.common_tags
}

resource "aws_eks_cluster" "mlops" {
  name = "mlops-${var.environment}"
  
  tags = local.common_tags
}
EOF

# Query costs by tag (AWS CLI)
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=TAG,Key=Project
```

**8. Set up cost alerts (AWS Budgets)**

```bash
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json

cat > budget.json << 'EOF'
{
  "BudgetName": "mlops-monthly-budget",
  "BudgetLimit": {
    "Amount": "1000",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostFilters": {
    "TagKeyValue": ["user:Project$mlops-course"]
  }
}
EOF
```

### Verify

```bash
# Check for secrets
gitleaks detect --source . --no-git
# Expected: no leaks

# Scan container
trivy image model-api:latest --severity HIGH,CRITICAL
# Expected: 0 vulnerabilities

# Verify secrets in K8s
kubectl get secrets -n mlops
# Expected: mlflow-creds present

# Check pod security
kubectl get pods -n mlops -o jsonpath='{.items[*].spec.securityContext}'
# Expected: runAsNonRoot: true
```

### Notes

- Never commit secrets to Git; use secrets managers.  
- Scan containers in CI; fail on HIGH/CRITICAL vulnerabilities.  
- Use least privilege IAM roles; never use root credentials.  
- Tag all cloud resources for cost tracking and chargeback.

### Mini-Lab (10 min)

**Objective**: Scan for secrets and vulnerabilities.

1. Create test secret:
   ```bash
   echo "AWS_SECRET_KEY=AKIAIOSFODNN7EXAMPLE" > test_secret.txt
   ```

2. Scan with Gitleaks:
   ```bash
   gitleaks detect --source . --no-git
   # Expected: secret detected
   ```

3. Remove secret:
   ```bash
   rm test_secret.txt
   ```

4. Scan container:
   ```bash
   docker build -t test:latest .
   trivy image test:latest
   # Expected: list of vulnerabilities
   ```

5. Generate SBOM:
   ```bash
   syft test:latest -o json > sbom.json
   cat sbom.json | jq '.artifacts | length'
   # Expected: number of dependencies
   ```

**Expected outcome**: Secret detected and removed; vulnerabilities listed; SBOM generated.

### Quiz (5 Questions)

1. What is SBOM?  
   → Software Bill of Materials—list of all dependencies for security audits.

2. Why scan containers for vulnerabilities?  
   → Detect known security issues before deploying to production.

3. What is least privilege?  
   → Grant minimum permissions needed; reduces blast radius.

4. What is PII?  
   → Personally Identifiable Information—must be protected by law (GDPR).

5. Why tag cloud resources?  
   → Track costs by project, team, or environment for chargeback.

### Common Mistakes

- Committing secrets to Git → exposed credentials.  
- Not scanning containers → deploy vulnerable images.  
- Using root user → security risk if compromised.  
- No cost monitoring → surprise bills at end of month.

### Troubleshooting

See `/troubleshooting/triage-matrix.md` for:  
- Gitleaks finds false positives → add to .gitleaksignore.  
- Trivy scan slow → use --timeout flag, cache DB locally.  
- Secrets not mounting in pods → check secret name, namespace.

---

# CHAPTER 14: COMPREHENSIVE REVIEW

## End-to-End MLOps Scenario

**Scenario**: Build churn prediction system from scratch to production.

### Phase 1: Setup (Chapter 0-2)

1. Create project structure
2. Initialize Git, DVC, virtual environment
3. Set up Docker Compose with MLflow, MinIO, Postgres, Airflow
4. Configure pre-commit hooks

### Phase 2: Data (Chapter 3)

1. Ingest customer data from CRM
2. Version with DVC
3. Validate schema with Evidently
4. Push to remote storage (S3/MinIO)

### Phase 3: Experimentation (Chapter 4-6)

1. Train baseline model (Logistic Regression)
2. Log to MLflow with params, metrics, artifacts
3. Train improved models (Random Forest, XGBoost)
4. Compare experiments, select best

### Phase 4: Pipeline (Chapter 7-8)

1. Create Airflow DAG: prepare → train → evaluate → register
2. Register best model in MLflow Registry
3. Transition to Staging
4. Manual approval gate
5. Promote to Production

### Phase 5: Deployment (Chapter 9-10)

1. Build FastAPI serving container
2. Add health/readiness checks
3. Push to container registry
4. Deploy to Kubernetes with HPA
5. Run smoke tests

### Phase 6: Monitoring (Chapter 11-12)

1. Instrument API with Prometheus metrics
2. Create Grafana dashboards (request rate, latency, errors)
3. Set up drift detection with Evidently
4. Configure retraining pipeline triggered by drift

### Phase 7: Security & Cost (Chapter 13)

1. Scan code for secrets (Gitleaks)
2. Scan container for vulnerabilities (Trivy)
3. Use Kubernetes Secrets for credentials
4. Tag resources for cost tracking
5. Set budget alerts

### Acceptance Criteria

- [ ] Local stack runs: `docker compose up`
- [ ] Data versioned with DVC
- [ ] Experiments tracked in MLflow
- [ ] Best model registered and staged
- [ ] CI/CD pipeline passes (tests, scans, build)
- [ ] API deployed to dev and prod
- [ ] Metrics visible in Grafana
- [ ] Drift detection runs daily
- [ ] No HIGH/CRITICAL vulnerabilities
- [ ] Cost tracking enabled

### Common Issues & Solutions

**Issue**: Training OOM  
**Solution**: Reduce batch size, use smaller model, add swap

**Issue**: API latency >500ms  
**Solution**: Model too large, add caching, use GPU, optimize preprocessing

**Issue**: Drift alerts firing constantly  
**Solution**: Adjust test thresholds, check data quality

**Issue**: Kubernetes CrashLoopBackOff  
**Solution**: Check logs, health checks, resource limits

**Issue**: MLflow artifacts not saving  
**Solution**: Verify S3 endpoint, credentials, bucket permissions

---

# CAPSTONE PROJECT: "Churn Predictor"

## Project Overview

Build end-to-end MLOps system predicting customer churn with dev and prod overlays.

## Architecture

```
Dev Overlay (Docker Compose):
- Local MLflow, MinIO, Postgres, Airflow
- FastAPI on localhost:8000
- Prometheus/Grafana monitoring

Prod Overlay (Kubernetes):
- External S3, RDS
- KServe/BentoML serving
- HPA, TLS ingress
- External secrets manager
- Multi-region deployment
```

## Pipeline

```mermaid
graph LR
    A[Raw Data] --> B[DVC Ingest]
    B --> C[Validate Schema]
    C --> D[Feature Engineering]
    D --> E[Train Model]
    E --> F[Evaluate]
    F --> G{Metrics Good?}
    G -->|Yes| H[Register Model]
    G -->|No| E
    H --> I[Staging Deploy]
    I --> J{Approval}
    J -->|Approved| K[Prod Deploy]
    K --> L[Monitor]
    L --> M{Drift?}
    M -->|Yes| E
    M -->|No| L
```

## Implementation Steps

### 1. Dev Overlay Setup

```bash
# Clone repo
git clone https://github.com/yourorg/churn-predictor
cd churn-predictor

# Start local stack
docker compose up -d

# Verify
curl http://localhost:5000/health  # MLflow
curl http://localhost:8000/health  # API
curl http://localhost:9090/-/healthy  # Prometheus
```

### 2. Data Preparation

```bash
# Generate sample data
python scripts/generate_data.py --output data/raw/customers.csv --samples 10000

# Track with DVC
dvc add data/raw/customers.csv
git add data/raw/customers.csv.dvc
git commit -m "data: add customer dataset"
dvc push

# Validate
python src/data/validate.py --input data/raw/customers.csv
```

### 3. Training

```bash
# Prepare data
python src/data/prepare.py

# Train multiple models
python src/models/train.py --model logistic --n_estimators 1
python src/models/train.py --model rf --n_estimators 50
python src/models/train.py --model rf --n_estimators 100

# Select best
python src/models/select_best.py --experiment churn-classification
```

### 4. Registry

```bash
# Register best model
python register_model.py --model-name churn-predictor

# Transition to Staging
python transition_model.py --name churn-predictor --stage Staging

# Test staging
python test_staging.py
```

### 5. CI/CD

```bash
# Run tests locally
pytest tests/ -v

# Scan for secrets
gitleaks detect --source . --no-git

# Build container
docker build -t churn-predictor:v1 .

# Scan container
trivy image churn-predictor:v1 --severity HIGH,CRITICAL

# Push to registry
docker tag churn-predictor:v1 ghcr.io/yourorg/churn-predictor:v1
docker push ghcr.io/yourorg/churn-predictor:v1
```

### 6. Deployment

**Dev:**
```bash
docker compose up -d
```

**Prod:**
```bash
# Apply K8s manifests
kubectl apply -f infra/k8s/base/namespace.yaml
kubectl apply -f infra/k8s/overlays/prod/

# Wait for rollout
kubectl rollout status deployment/model-api -n mlops

# Smoke test
kubectl port-forward svc/model-api 8000:80 -n mlops &
curl http://localhost:8000/health
```

### 7. Monitoring

```bash
# Generate traffic
for i in {1..1000}; do
  curl -X POST http://localhost:8000/predict \
    -H "Content-Type: application/json" \
    -d '{"age": 35, "tenure": 12, "monthly_charges": 70.0}' &
done
wait

# Check Grafana
open http://localhost:3000
# Username: admin, Password: admin
```

### 8. Drift Detection & Retraining

```bash
# Run drift detection
python src/monitoring/detect_drift.py

# If drift detected, trigger retrain
docker exec airflow airflow dags trigger retraining_pipeline

# Monitor progress
docker exec airflow airflow dags list-runs -d retraining_pipeline
```

## Failure Injection & Recovery

### Scenario 1: Bad Schema

```bash
# Inject bad data
echo "bad,schema,missing,columns" > data/processed/current.csv

# Run validation
python src/data/validate.py --input data/processed/current.csv
# Expected: Validation fails

# Fix
python src/data/prepare.py
```

### Scenario 2: Model Serving Failure

```bash
# Kill API container
docker stop api

# Check health
curl http://localhost:8000/health
# Expected: Connection refused

# Recover
docker compose up -d api

# Verify
curl http://localhost:8000/health
# Expected: {"status":"healthy"}
```

### Scenario 3: Drift Detected

```bash
# Generate drifted data
python scripts/generate_drift.py --output data/processed/current.csv

# Detect drift
python src/monitoring/detect_drift.py
# Expected: Exit code 1 (drift detected)

# Trigger retraining
docker exec airflow airflow dags trigger retraining_pipeline

# Monitor
docker exec airflow airflow dags list-runs -d retraining_pipeline --state running
```

## Deliverables

- [ ] Git repo with full project structure
- [ ] docker-compose.yml for local dev
- [ ] Kubernetes manifests for prod
- [ ] CI/CD pipeline (.github/workflows/)
- [ ] Documentation (README, model card)
- [ ] Smoke tests passing
- [ ] Monitoring dashboards
- [ ] Drift detection working

---

# TROUBLESHOOTING PACK

## Triage Matrix

| **Symptom** | **Triage Commands** | **Likely Root Causes** | **Fix** | **Verify** | **Prevent** |
|-------------|---------------------|------------------------|---------|------------|-------------|
| Training OOM | `dmesg | grep -i oom`<br>`free -h` | Model too large, batch size too big | Reduce batch size, use gradient accumulation, add swap | `nvidia-smi` (if GPU) | Monitor memory during training |
| Training slow | `top`, `nvidia-smi` | No GPU, inefficient code, large dataset | Use GPU, profile code, sample data | Training completes in reasonable time | Benchmark before scaling |
| CUDA missing | `nvcc --version`<br>`nvidia-smi` | Wrong driver, wrong CUDA version | Install correct CUDA toolkit, update driver | `torch.cuda.is_available()` returns True | Docker image with CUDA |
| DVC remote denied | `dvc push -v`<br>`aws s3 ls` | Wrong credentials, no permissions | Check AWS keys, IAM policy | `dvc push` succeeds | Use IAM roles, not keys |
| MLflow down | `curl http://localhost:5000/health` | Container not running, DB connection failed | `docker compose up mlflow`, check DB | MLflow UI loads | Health checks in compose |
| Schema mismatch | `python -c "import pandas as pd; pd.read_csv('data.csv').dtypes"` | Data changed, code expects old schema | Update schema, re-validate data | Validation passes | Schema versioning |
| API 500 error | `docker logs api`<br>`curl /health` | Model not loaded, bug in code | Check logs, restart container | Request succeeds | Add error handling |
| p95 latency spike | `curl /metrics | grep latency`<br>`kubectl top pods` | Model too large, high load, network slow | Add caching, scale replicas, optimize model | Latency <100ms | Load testing before prod |
| Drift floods | Check drift report thresholds | Test too sensitive, bad data | Adjust thresholds, validate data | Drift alerts actionable | Baseline on clean data |
| Pipeline stuck | `airflow tasks list -d <dag>`<br>`airflow tasks state` | Dependency failed, resource limit | Check logs, clear failed task | Pipeline completes | Retries, alerts |
| CrashLoopBackOff | `kubectl describe pod <pod>`<br>`kubectl logs <pod>` | Bad health check, app crash, missing secret | Fix health check, check logs, add secret | Pod Running | Test locally first |
| ImagePullBackOff | `kubectl describe pod <pod>` | Wrong image tag, no registry access | Check tag, add imagePullSecret | Pod Running | Test image exists |
| HPA not scaling | `kubectl get hpa`<br>`kubectl top nodes` | Metrics server down, no load | Install metrics-server, generate load | Replicas increase | Test autoscaling |

---

# CHEAT SHEETS

## Python Environment Cheat Sheet

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create venv
uv venv --python 3.11

# Activate
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows

# Install from pyproject.toml
uv pip install -e ".[dev]"

# Add package
uv pip install pandas scikit-learn

# Generate lock file
uv pip freeze > requirements.lock

# Deactivate
deactivate
```

## DVC & MLflow Cheat Sheet

```bash
# DVC
dvc init
dvc add data/raw/dataset.csv
dvc push
dvc pull
dvc remote add -d s3 s3://bucket/path
dvc repro  # Run pipeline

# MLflow
export MLFLOW_TRACKING_URI=http://localhost:5000

# Log experiment
mlflow.log_param("lr", 0.01)
mlflow.log_metric("accuracy", 0.95)
mlflow.log_artifact("plot.png")
mlflow.sklearn.log_model(model, "model")

# Register model
mlflow.register_model("runs:/<run_id>/model", "model-name")

# Load model
mlflow.pyfunc.load_model("models:/model-name/Production")

# CLI
mlflow experiments list
mlflow runs list --experiment-id 1
mlflow models list
```

## Docker & Kubernetes Cheat Sheet

```bash
# Docker
docker build -t myapp:latest .
docker run -d -p 8000:8000 myapp:latest
docker ps
docker logs <container>
docker exec -it <container> bash
docker compose up -d
docker compose down -v

# Kubernetes
kubectl apply -f deployment.yaml
kubectl get pods -n mlops
kubectl describe pod <pod> -n mlops
kubectl logs <pod> -n mlops
kubectl exec -it <pod> -n mlops -- bash
kubectl port-forward svc/api 8000:80 -n mlops
kubectl delete pod <pod> -n mlops
kubectl get hpa
kubectl top pods
```

## Airflow & Kubeflow Pipelines Cheat Sheet

```bash
# Airflow
docker exec airflow airflow dags list
docker exec airflow airflow dags trigger <dag_id>
docker exec airflow airflow dags list-runs -d <dag_id>
docker exec airflow airflow tasks list -d <dag_id>
docker exec airflow airflow tasks test <dag_id> <task_id> 2024-01-01
docker exec airflow airflow dags pause <dag_id>
docker exec airflow airflow dags unpause <dag_id>

# Kubeflow Pipelines
pip install kfp
kfp pipeline upload-version <pipeline_id> <yaml>
kfp run submit -e <experiment> -p <pipeline_id> <args>
kfp run list
kfp run get <run_id>
```

## Monitoring Cheat Sheet

```bash
# Prometheus
# Query API
curl 'http://localhost:9090/api/v1/query?query=up'

# PromQL examples
rate(http_requests_total[5m])
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
increase(errors_total[1h])

# Grafana
# Default: http://localhost:3000
# Username: admin, Password: admin

# Curl metrics endpoint
curl http://localhost:8000/metrics

# Common metrics to track
- request_count
- request_latency (p50, p95, p99)
- error_rate
- model_prediction_distribution
```

---

# MOCK EXAM 1

**Time: 90 minutes | 15 tasks**

## Task 1: Environment Setup (5 min)
Create project structure, initialize Git, DVC, and virtual environment with Python 3.11.

**Solution:**
```bash
mkdir mlops-exam && cd mlops-exam
git init
dvc init
uv venv --python 3.11
source .venv/bin/activate
uv pip install mlflow pandas scikit-learn
git add .dvc .gitignore
git commit -m "feat: init project"
```

## Task 2: Data Versioning (5 min)
Generate 1000-row CSV dataset, track with DVC, push to local remote.

**Solution:**
```bash
python -c "import pandas as pd; import numpy as np; pd.DataFrame({'x': np.random.rand(1000), 'y': np.random.randint(0,2,1000)}).to_csv('data.csv', index=False)"
dvc remote add -d local /tmp/dvc-remote
dvc add data.csv
git add data.csv.dvc .dvc/config
git commit -m "data: add dataset"
dvc push
```

## Task 3: Experiment Tracking (10 min)
Train Logistic Regression on dataset, log params/metrics to MLflow.

**Solution:**
```bash
export MLFLOW_TRACKING_URI=http://localhost:5000
python << EOF
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import mlflow

df = pd.read_csv('data.csv')
X_train, X_test, y_train, y_test = train_test_split(df[['x']], df['y'], test_size=0.2)

mlflow.set_experiment("exam")
with mlflow.start_run():
    model = LogisticRegression()
    model.fit(X_train, y_train)
    acc = accuracy_score(y_test, model.predict(X_test))
    mlflow.log_param("model", "LogisticRegression")
    mlflow.log_metric("accuracy", acc)
    mlflow.sklearn.log_model(model, "model")
    print(f"Accuracy: {acc}")
EOF
```

## Task 4: Model Registry (5 min)
Register best model from previous task.

**Solution:**
```bash
python << EOF
import mlflow
client = mlflow.MlflowClient()
runs = client.search_runs(experiment_ids=["1"], order_by=["metrics.accuracy DESC"], max_results=1)
run_id = runs[0].info.run_id
mlflow.register_model(f"runs:/{run_id}/model", "exam-model")
EOF
```

## Task 5: FastAPI Serving (10 min)
Create FastAPI app with /health and /predict endpoints.

**Solution:**
```bash
cat > app.py << 'EOF'
from fastapi import FastAPI
from pydantic import BaseModel
import mlflow

app = FastAPI()
model = mlflow.pyfunc.load_model("models:/exam-model/1")

class Request(BaseModel):
    x: float

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict")
def predict(req: Request):
    import pandas as pd
    pred = model.predict(pd.DataFrame([req.dict()]))
    return {"prediction": int(pred[0])}
EOF

uvicorn app:app --host 0.0.0.0 --port 8000 &
sleep 3
curl http://localhost:8000/health
curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"x": 0.5}'
pkill uvicorn
```

## Task 6: Dockerfile (10 min)
Create Dockerfile for FastAPI app, build and run.

**Solution:**
```bash
cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
RUN pip install fastapi uvicorn mlflow scikit-learn pandas
COPY app.py .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

docker build -t exam-api .
docker run -d -p 8000:8000 --name exam-api exam-api
curl http://localhost:8000/health
docker stop exam-api && docker rm exam-api
```

## Task 7-15: Abbreviated

**Task 7:** Create Airflow DAG with 3 sequential tasks.  
**Task 8:** Add Prometheus metrics to API (/metrics endpoint).  
**Task 9:** Write drift detection script using Evidently.  
**Task 10:** Create Kubernetes Deployment with 2 replicas.  
**Task 11:** Add HPA to scale 2-10 replicas at 70% CPU.  
**Task 12:** Scan container with Trivy, fail on HIGH.  
**Task 13:** Create .gitleaksignore to ignore false positives.  
**Task 14:** Generate SBOM with Syft.  
**Task 15:** Create pre-commit config with ruff and gitleaks hooks.

---

# MOCK EXAM 2

**Time: 90 minutes | 12 tasks**

## Task 1: Full Pipeline (15 min)
Build end-to-end pipeline: data → train → register → deploy.

## Task 2: Monitoring Dashboard (10 min)
Create Grafana dashboard with request rate and latency panels.

## Task 3: Drift Detection (10 min)
Implement drift detector comparing current vs. baseline data.

## Task 4: CI/CD Pipeline (15 min)
Create GitHub Actions workflow: test → build → scan → deploy.

## Task 5: Kubernetes Deployment (10 min)
Deploy API to K8s with HPA, health checks, and secrets.

## Task 6: Security Scan (5 min)
Run Trivy scan on container, fix vulnerabilities.

## Task 7: Cost Optimization (10 min)
Add resource limits to K8s deployment, tag resources.

## Task 8: Model Card (5 min)
Create model card documenting performance, limitations, ethics.

## Task 9: Rollback (5 min)
Simulate failed deployment, rollback to previous version.

## Task 10: Load Testing (10 min)
Send 1000 requests/sec, verify p95 latency <100ms.

## Task 11: Drift Retraining (10 min)
Detect drift, trigger retraining pipeline, register new model.

## Task 12: Documentation (5 min)
Write README with quickstart, architecture diagram, troubleshooting.

---

## Solutions Available

Full solutions with commands provided in separate file `mock-exam-solutions.md`.

---

# CONCLUSION

You've completed the **MLOps Course: Beginner → Production**!

**Key Takeaways:**
1. MLOps = ML + DevOps (automate everything)
2. Version data (DVC), experiments (MLflow), code (Git)
3. Build pipelines (Airflow/Kubeflow) for reproducibility
4. Deploy with CI/CD (GitHub Actions) + K8s (HPA, health checks)
5. Monitor (Prometheus/Grafana) + detect drift (Evidently)
6. Secure (scan secrets/vulnerabilities) + optimize costs (tag resources)

**Next Steps:**
- Build your own project end-to-end
- Contribute to open-source MLOps tools
- Get certified (Kubernetes, cloud providers)
- Join MLOps community (meetups, conferences)

**Resources:**
- [MLflow Docs](https://mlflow.org/docs/latest/index.html)
- [DVC Docs](https://dvc.org/doc)
- [Kubeflow](https://www.kubeflow.org/)
- [Evidently](https://docs.evidentlyai.com/)
- [MLOps Community](https://mlops.community/)

**Good luck on your MLOps journey!** 🚀


# MLOps Churn Predictor - Capstone Project

End-to-end MLOps system for customer churn prediction.

## Quick Start

### Local Development
```bash
cd project
docker compose up -d
```

Access services:
- MLflow: http://localhost:5000
- Airflow: http://localhost:8080 (admin/admin)
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)
- MinIO: http://localhost:9001 (minioadmin/minioadmin)

### Training
```bash
python src/data/prepare.py
python src/models/train.py
```

### Deployment
```bash
# Dev
docker compose up -d

# Prod
kubectl apply -f infra/k8s/overlays/prod/
```

## Architecture

**Dev**: Docker Compose stack with local MLflow, MinIO, Postgres, Airflow  
**Prod**: Kubernetes with KServe, external S3, HPA, TLS

## Pipeline

1. Data ingestion (DVC)
2. Validation (Evidently)
3. Training (MLflow)
4. Registration (Model Registry)
5. Deployment (Kubernetes)
6. Monitoring (Prometheus/Grafana)
7. Drift detection (Evidently)
8. Retraining (Airflow)

## Documentation

See `/MLOps-Course.md` for complete course material.

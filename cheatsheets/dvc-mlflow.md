# DVC & MLflow Cheat Sheet

## DVC Commands
```bash
# Initialize
dvc init
dvc remote add -d s3 s3://bucket/path

# Track data
dvc add data/raw/dataset.csv
git add data/raw/dataset.csv.dvc
git commit -m "data: add dataset"

# Push/Pull
dvc push
dvc pull

# Pipeline
dvc repro
dvc dag
```

## MLflow Commands
```bash
# Set tracking server
export MLFLOW_TRACKING_URI=http://localhost:5000

# Python API
mlflow.set_experiment("my-experiment")
with mlflow.start_run():
    mlflow.log_param("lr", 0.01)
    mlflow.log_metric("accuracy", 0.95)
    mlflow.log_artifact("plot.png")
    mlflow.sklearn.log_model(model, "model")

# Register model
mlflow.register_model("runs:/<run_id>/model", "model-name")

# Load model
model = mlflow.pyfunc.load_model("models:/model-name/Production")

# CLI
mlflow experiments list
mlflow runs list --experiment-id 1
mlflow models list
```

# Airflow & Kubeflow Pipelines Cheat Sheet

## Airflow
```bash
# Docker exec commands
docker exec airflow airflow dags list
docker exec airflow airflow dags trigger <dag_id>
docker exec airflow airflow dags list-runs -d <dag_id>
docker exec airflow airflow tasks list -d <dag_id>
docker exec airflow airflow tasks test <dag_id> <task_id> 2024-01-01
docker exec airflow airflow dags pause <dag_id>
docker exec airflow airflow dags unpause <dag_id>
docker exec airflow airflow tasks clear <dag_id>
```

## Kubeflow Pipelines
```bash
# Install SDK
pip install kfp

# Compile pipeline
from kfp import compiler
compiler.Compiler().compile(pipeline_func, 'pipeline.yaml')

# CLI
kfp pipeline upload-version <pipeline_id> pipeline.yaml
kfp run submit -e experiment -p pipeline_id
kfp run list
kfp run get <run_id>
```

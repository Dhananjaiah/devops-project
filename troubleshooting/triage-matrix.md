# MLOps Troubleshooting Matrix

## Training Issues

### Training OOM (Out of Memory)
**Triage**: `dmesg | grep -i oom`, `free -h`, `nvidia-smi`  
**Causes**: Model too large, batch size too big, memory leak  
**Fix**: Reduce batch size, use gradient accumulation, add swap, use smaller model  
**Verify**: Training completes without crash  
**Prevent**: Monitor memory usage, set resource limits

### Training Slow
**Triage**: `top`, `htop`, `nvidia-smi`  
**Causes**: No GPU, inefficient code, large dataset, network bottleneck  
**Fix**: Use GPU, profile code (`cProfile`), sample data, cache data locally  
**Verify**: Training time acceptable for dataset size  
**Prevent**: Benchmark before scaling, optimize data loading

### CUDA Not Available
**Triage**: `nvcc --version`, `nvidia-smi`, `torch.cuda.is_available()`  
**Causes**: Wrong driver, wrong CUDA version, Docker misconfiguration  
**Fix**: Install correct CUDA toolkit, update NVIDIA driver, use `--gpus all` flag  
**Verify**: `nvidia-smi` works, PyTorch detects GPU  
**Prevent**: Use official CUDA Docker images

## Data Issues

### DVC Remote Access Denied
**Triage**: `dvc push -v`, `aws s3 ls s3://bucket`, `dvc remote list`  
**Causes**: Wrong credentials, IAM permissions, endpoint URL incorrect  
**Fix**: Check `AWS_ACCESS_KEY_ID`, update IAM policy, verify endpoint  
**Verify**: `dvc push` succeeds  
**Prevent**: Use IAM roles instead of access keys, test connection

### Schema Mismatch
**Triage**: `pandas.read_csv().dtypes`, check validation logs  
**Causes**: Data schema changed, code expects old format  
**Fix**: Update schema definition, re-validate data, fix transformations  
**Verify**: Validation passes, training succeeds  
**Prevent**: Version schemas, add schema validation to pipeline

## Service Issues

### MLflow Server Down
**Triage**: `curl http://localhost:5000/health`, `docker logs mlflow`, `docker ps`  
**Causes**: Container not running, database connection failed, port conflict  
**Fix**: `docker compose up mlflow`, check DB connectivity, change port  
**Verify**: MLflow UI accessible, can log runs  
**Prevent**: Health checks, monitor service, use restart policy

### API Returning 500 Errors
**Triage**: `docker logs api`, `curl /health`, check application logs  
**Causes**: Model not loaded, bug in code, missing dependencies  
**Fix**: Check logs for stack trace, restart container, fix code  
**Verify**: Requests return 200 with correct predictions  
**Prevent**: Unit tests, error handling, load testing

### High Latency (p95 > 500ms)
**Triage**: `curl /metrics`, `kubectl top pods`, check Grafana  
**Causes**: Model too large, high load, network slow, cold start  
**Fix**: Optimize model, add caching, scale replicas, preload model  
**Verify**: p95 latency < 100ms under normal load  
**Prevent**: Load testing, set SLOs, autoscaling

## Drift & Monitoring

### Drift Alerts Constantly Firing
**Triage**: Check drift report, review thresholds, inspect current data  
**Causes**: Test too sensitive, bad data quality, legitimate drift  
**Fix**: Adjust thresholds, fix data quality issues, retrain model  
**Verify**: Alerts actionable, not noisy  
**Prevent**: Baseline on clean data, tune thresholds gradually

### Prometheus Targets Down
**Triage**: `curl http://prometheus:9090/targets`, check network, firewall  
**Causes**: Service not exposing /metrics, network issue, wrong port  
**Fix**: Verify /metrics endpoint, check firewall rules, fix port  
**Verify**: Target shows "UP" in Prometheus  
**Prevent**: Test endpoints, add health checks

## Pipeline Issues

### Airflow DAG Not Appearing
**Triage**: Check DAG file syntax, `airflow dags list`, check logs  
**Causes**: Syntax error, import error, wrong directory  
**Fix**: Fix syntax, install missing packages, check DAG path  
**Verify**: DAG visible in UI  
**Prevent**: Test DAGs locally, use `airflow dags test`

### Pipeline Tasks Stuck
**Triage**: `airflow tasks state`, check logs, `kubectl get pods`  
**Causes**: Dependency failed, resource limits, deadlock  
**Fix**: Clear failed task, increase resources, fix dependencies  
**Verify**: Pipeline completes successfully  
**Prevent**: Set timeouts, add retries, monitor resources

## Kubernetes Issues

### CrashLoopBackOff
**Triage**: `kubectl describe pod`, `kubectl logs`, check events  
**Causes**: Bad health check, app crash on start, missing secret/configmap  
**Fix**: Fix health check (increase delay), debug app, add missing resources  
**Verify**: Pod status "Running"  
**Prevent**: Test locally, use readiness probe, validate configs

### ImagePullBackOff
**Triage**: `kubectl describe pod`, check image name, registry auth  
**Causes**: Wrong image tag, no registry access, typo in image name  
**Fix**: Check tag exists, add imagePullSecret, fix image name  
**Verify**: Pod pulls image successfully  
**Prevent**: Test image locally, automate image tagging

### HPA Not Scaling
**Triage**: `kubectl get hpa`, `kubectl top nodes`, check metrics-server  
**Causes**: Metrics server not installed, no load, wrong metric  
**Fix**: Install metrics-server, generate load, fix metric definition  
**Verify**: Replicas scale up/down based on load  
**Prevent**: Test autoscaling before production

## Security Issues

### Secrets Detected in Git
**Triage**: `gitleaks detect --source .`  
**Causes**: Hardcoded credentials, .env committed  
**Fix**: Remove from history (`git filter-branch`), rotate credentials  
**Verify**: `gitleaks` reports no leaks  
**Prevent**: Pre-commit hooks (gitleaks), .gitignore for secrets

### Container Vulnerabilities
**Triage**: `trivy image <image>`  
**Causes**: Outdated base image, vulnerable dependencies  
**Fix**: Update base image, update dependencies, apply patches  
**Verify**: `trivy` reports 0 HIGH/CRITICAL  
**Prevent**: Scan in CI, automated dependency updates

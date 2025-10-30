# Monitoring Cheat Sheet

## Prometheus Queries (PromQL)
```promql
# Request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status="500"}[5m]) / rate(http_requests_total[5m])

# Latency (p95)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# CPU usage
rate(process_cpu_seconds_total[5m])

# Memory usage
process_resident_memory_bytes

# Increase over time
increase(errors_total[1h])
```

## Grafana
```bash
# Default URL: http://localhost:3000
# Username: admin
# Password: admin

# Common panels:
- Time series (latency, request rate)
- Gauge (current value)
- Stat (single number)
- Pie chart (distribution)
```

## Common Metrics
```
# Golden Signals
- Latency: p50, p95, p99
- Traffic: requests/second
- Errors: error rate, error count
- Saturation: CPU, memory, disk

# ML Specific
- Prediction count
- Prediction distribution
- Model load time
- Feature fetch latency
```

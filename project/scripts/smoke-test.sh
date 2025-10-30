#!/bin/bash
# Smoke test for FoodCart application

set -e

NAMESPACE=${1:-foodcart-dev}

echo "🧪 Running smoke tests for namespace: ${NAMESPACE}"

# Check all pods are running
echo "✓ Checking pod status..."
oc wait --for=condition=ready pod -l app=foodcart -n ${NAMESPACE} --timeout=60s

# Test gateway endpoint
echo "✓ Testing gateway endpoint..."
ROUTE=$(oc get route -n ${NAMESPACE} -l service=gateway -o jsonpath='{.items[0].spec.host}')
PROTO=$(oc get route -n ${NAMESPACE} -l service=gateway -o jsonpath='{.items[0].spec.tls.termination}')
if [ -z "$PROTO" ]; then
  URL="http://${ROUTE}"
else
  URL="https://${ROUTE}"
fi

curl -sf -k ${URL} > /dev/null || { echo "❌ Gateway not accessible"; exit 1; }
echo "Gateway accessible at ${URL}"

# Test menu service (internal)
echo "✓ Testing menu service..."
GATEWAY_POD=$(oc get pod -n ${NAMESPACE} -l service=gateway -o jsonpath='{.items[0].metadata.name}')
oc exec ${GATEWAY_POD} -n ${NAMESPACE} -- wget -qO- --timeout=5 http://menu:8080 | grep -q "menu" || { echo "❌ Menu service failed"; exit 1; }
echo "Menu service OK"

# Test orders service (internal)
echo "✓ Testing orders service..."
oc exec ${GATEWAY_POD} -n ${NAMESPACE} -- wget -qO- --timeout=5 http://orders:8080 | grep -q "order" || { echo "❌ Orders service failed"; exit 1; }
echo "Orders service OK"

# Test payments service (internal)
echo "✓ Testing payments service..."
oc exec ${GATEWAY_POD} -n ${NAMESPACE} -- wget -qO- --timeout=5 http://payments:8080 | grep -q "payment" || { echo "❌ Payments service failed"; exit 1; }
echo "Payments service OK"

# Test database connectivity
echo "✓ Testing database connectivity..."
DB_POD=$(oc get pod -n ${NAMESPACE} -l service=db -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$DB_POD" ]; then
  oc exec ${DB_POD} -n ${NAMESPACE} -- pg_isready -U foodcart || { echo "❌ Database not ready"; exit 1; }
  echo "Database OK"
else
  echo "⚠ Database not found (may be external)"
fi

echo "✅ All smoke tests passed!"

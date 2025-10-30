#!/bin/bash
# Load test for FoodCart application (triggers HPA)

NAMESPACE=${1:-foodcart-prod}
DURATION=${2:-60}

echo "🔥 Running load test for ${DURATION} seconds on namespace: ${NAMESPACE}"

ROUTE=$(oc get route -n ${NAMESPACE} -l service=gateway -o jsonpath='{.items[0].spec.host}')
PROTO=$(oc get route -n ${NAMESPACE} -l service=gateway -o jsonpath='{.items[0].spec.tls.termination}')
if [ -z "$PROTO" ]; then
  URL="http://${ROUTE}"
else
  URL="https://${ROUTE}"
fi

echo "Target URL: ${URL}"
echo "Starting load test..."

# Run load test in background
for i in {1..10}; do
  (
    END=$((SECONDS+${DURATION}))
    while [ $SECONDS -lt $END ]; do
      curl -sk ${URL} > /dev/null 2>&1
      sleep 0.1
    done
  ) &
done

echo "Load test running. Monitor HPA with:"
echo "  oc get hpa -n ${NAMESPACE} -w"
echo ""
echo "Press Ctrl+C to stop early, or wait ${DURATION} seconds..."

wait
echo "✅ Load test complete"

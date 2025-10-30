#!/bin/bash
# Failure injection for chaos testing

SCENARIO=${1}
NAMESPACE=${2}
SERVICE=${3:-orders}

case "${SCENARIO}" in
  pod-crash)
    echo "💥 Injecting pod crash for ${SERVICE} in ${NAMESPACE}"
    POD=$(oc get pod -n ${NAMESPACE} -l service=${SERVICE} -o jsonpath='{.items[0].metadata.name}')
    oc delete pod ${POD} -n ${NAMESPACE}
    echo "Pod ${POD} deleted. Kubernetes will recreate it."
    ;;
    
  block-dns)
    echo "🚫 Blocking DNS egress in ${NAMESPACE}"
    oc delete networkpolicy allow-dns-egress -n ${NAMESPACE} 2>/dev/null || true
    echo "DNS egress blocked. Services will fail to resolve names."
    echo "To fix: oc apply -f manifests/overlays/prod/networkpolicies.yaml"
    ;;
    
  scale-down)
    echo "📉 Scaling down ${SERVICE} to 0 replicas in ${NAMESPACE}"
    oc scale deployment/${SERVICE} --replicas=0 -n ${NAMESPACE}
    echo "Service ${SERVICE} scaled to 0. Traffic will fail."
    echo "To fix: oc scale deployment/${SERVICE} --replicas=2 -n ${NAMESPACE}"
    ;;
    
  high-cpu)
    echo "🔥 Injecting CPU stress on ${SERVICE} in ${NAMESPACE}"
    POD=$(oc get pod -n ${NAMESPACE} -l service=${SERVICE} -o jsonpath='{.items[0].metadata.name}')
    oc exec ${POD} -n ${NAMESPACE} -- sh -c "yes > /dev/null &" 2>/dev/null || echo "Note: stress command may not be available in all images"
    echo "CPU stress injected (if supported by image)."
    ;;
    
  *)
    echo "Usage: $0 <scenario> <namespace> [service]"
    echo ""
    echo "Scenarios:"
    echo "  pod-crash    - Delete a pod (tests restart policy)"
    echo "  block-dns    - Remove DNS egress NetworkPolicy"
    echo "  scale-down   - Scale service to 0 replicas"
    echo "  high-cpu     - Inject CPU stress (triggers HPA)"
    exit 1
    ;;
esac

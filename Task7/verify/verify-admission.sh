#!/bin/bash

echo "=== Verifying PodSecurity Admission and Gatekeeper ==="
echo

# Check if namespace exists
echo "1. Checking namespace audit-zone..."
kubectl get namespace audit-zone > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Namespace audit-zone exists"
    kubectl get namespace audit-zone -o yaml | grep -A 3 "pod-security.kubernetes.io"
else
    echo "✗ Namespace audit-zone does not exist"
fi

echo

# Check Gatekeeper installation
echo "2. Checking OPA Gatekeeper installation..."
kubectl get namespace gatekeeper-system > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Gatekeeper namespace exists"
    kubectl get pods -n gatekeeper-system
else
    echo "✗ Gatekeeper is not installed"
fi

echo

# Check constraint templates
echo "3. Checking Constraint Templates..."
kubectl get constrainttemplates
echo

# Check constraints
echo "4. Checking Constraints..."
kubectl get constraints
echo

# Test insecure manifests
echo "5. Testing insecure manifests (should fail)..."
echo "Testing privileged pod..."
kubectl apply -f insecure-manifests/01-privileged-pod.yaml --dry-run=server 2>&1 | grep -E "(forbidden|denied|error)" && echo "✓ Privileged pod blocked" || echo "✗ Privileged pod allowed"

echo "Testing hostpath pod..."
kubectl apply -f insecure-manifests/02-hostpath-pod.yaml --dry-run=server 2>&1 | grep -E "(forbidden|denied|error)" && echo "✓ HostPath pod blocked" || echo "✗ HostPath pod allowed"

echo "Testing root user pod..."
kubectl apply -f insecure-manifests/03-root-user-pod.yaml --dry-run=server 2>&1 | grep -E "(forbidden|denied|error)" && echo "✓ Root user pod blocked" || echo "✗ Root user pod allowed"

echo

# Test secure manifests
echo "6. Testing secure manifests (should pass)..."
echo "Testing secure pod 1..."
kubectl apply -f secure-manifests/01-secure.yaml --dry-run=server > /dev/null 2>&1 && echo "✓ Secure pod 1 accepted" || echo "✗ Secure pod 1 rejected"

echo "Testing secure pod 2..."
kubectl apply -f secure-manifests/02-secure.yaml --dry-run=server > /dev/null 2>&1 && echo "✓ Secure pod 2 accepted" || echo "✗ Secure pod 2 rejected"

echo "Testing secure pod 3..."
kubectl apply -f secure-manifests/03-secure.yaml --dry-run=server > /dev/null 2>&1 && echo "✓ Secure pod 3 accepted" || echo "✗ Secure pod 3 rejected"

echo
echo "=== Verification Complete ==="
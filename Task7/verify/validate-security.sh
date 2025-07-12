#!/bin/bash

echo "=== Security Validation Report ==="
echo

# Function to check pod security context
check_pod_security() {
    local file=$1
    local pod_name=$2

    echo "Checking $pod_name ($file):"

    # Check privileged
    if grep -q "privileged: true" "$file"; then
        echo "  ✗ Uses privileged mode"
    else
        echo "  ✓ Not privileged"
    fi

    # Check runAsNonRoot
    if grep -q "runAsNonRoot: true" "$file"; then
        echo "  ✓ Runs as non-root"
    else
        echo "  ✗ Does not specify runAsNonRoot"
    fi

    # Check readOnlyRootFilesystem
    if grep -q "readOnlyRootFilesystem: true" "$file"; then
        echo "  ✓ Read-only root filesystem"
    else
        echo "  ✗ Does not use read-only root filesystem"
    fi

    # Check hostPath
    if grep -q "hostPath" "$file"; then
        echo "  ✗ Uses hostPath volume"
    else
        echo "  ✓ No hostPath volumes"
    fi

    # Check runAsUser
    if grep -q "runAsUser: 0" "$file"; then
        echo "  ✗ Runs as root (UID 0)"
    else
        echo "  ✓ Does not run as root"
    fi

    echo
}

# Check insecure manifests
echo "=== Insecure Manifests ==="
check_pod_security "insecure-manifests/01-privileged-pod.yaml" "privileged-pod"
check_pod_security "insecure-manifests/02-hostpath-pod.yaml" "hostpath-pod"
check_pod_security "insecure-manifests/03-root-user-pod.yaml" "root-user-pod"

# Check secure manifests
echo "=== Secure Manifests ==="
check_pod_security "secure-manifests/01-secure.yaml" "secure-pod-1"
check_pod_security "secure-manifests/02-secure.yaml" "secure-pod-2"
check_pod_security "secure-manifests/03-secure.yaml" "secure-pod-3"

echo "=== Validation Complete ==="
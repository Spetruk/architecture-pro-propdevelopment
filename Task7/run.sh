#!/bin/bash

echo "=== Правильная последовательность развертывания Gatekeeper ==="
echo

# 1. Убедиться, что Gatekeeper установлен и работает
echo "1. Проверяем статус Gatekeeper..."
kubectl get pods -n gatekeeper-system
if [ $? -ne 0 ]; then
    echo "Gatekeeper не установлен. Устанавливаем..."
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

    echo "Ожидаем готовности Gatekeeper..."
    kubectl wait --for=condition=Ready pod -l control-plane=controller-manager -n gatekeeper-system --timeout=300s
    kubectl wait --for=condition=Ready pod -l control-plane=audit-controller -n gatekeeper-system --timeout=300s
fi

echo

# 2. Применить constraint templates
echo "2. Применяем Constraint Templates..."
kubectl apply -f gatekeeper/constraint-templates/

echo

# 3. Ждем, пока Gatekeeper создаст CRD
echo "3. Ожидаем создания CRD (это может занять несколько минут)..."
echo "Проверяем создание CRD..."

# Функция для проверки CRD
check_crd() {
    local crd_name=$1
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        kubectl get crd $crd_name > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✓ CRD $crd_name создан"
            return 0
        fi
        echo "Попытка $attempt/$max_attempts: ожидаем CRD $crd_name..."
        sleep 10
        ((attempt++))
    done

    echo "✗ CRD $crd_name не был создан в течение 5 минут"
    return 1
}

# Проверяем все CRD
check_crd "k8srequiredprivileged.constraints.gatekeeper.sh"
check_crd "k8sblockallhostpaths.constraints.gatekeeper.sh"
check_crd "k8srequirerunasnonroot.constraints.gatekeeper.sh"

echo

# 4. Применить constraints
echo "4. Применяем Constraints..."
kubectl apply -f gatekeeper/constraints/

echo

# 5. Проверить результат
echo "5. Проверяем результат..."
echo "Constraint Templates:"
kubectl get constrainttemplates

echo
echo "Constraints:"
kubectl get constraints

echo
echo "=== Развертывание завершено ==="
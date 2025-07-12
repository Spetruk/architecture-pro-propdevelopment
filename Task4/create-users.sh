#!/bin/bash

# Скрипт создания пользователей для namespace sales
# Создает администратора и разработчика

set -e

echo "🚀 Создание пользователей для namespace sales"
echo "============================================="

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Создание директории для пользователей
USERS_DIR="./users"
mkdir -p $USERS_DIR

# Получение информации о кластере
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

log "Кластер: $CLUSTER_NAME"
log "Сервер: $CLUSTER_SERVER"

# Создание CA файла
log "Получение CA сертификата..."
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d > $USERS_DIR/ca.crt

# Функция создания пользователя
create_user() {
    local username=$1
    local description=$2

    log "Создание пользователя: $username"

    # Создание приватного ключа
    openssl genrsa -out $USERS_DIR/${username}.key 2048

    # Создание запроса на сертификат
    openssl req -new -key $USERS_DIR/${username}.key -out $USERS_DIR/${username}.csr \
        -subj "/CN=${username}/O=sales"

    # Создание Kubernetes CSR
    cat > $USERS_DIR/${username}-csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${username}
spec:
  request: $(cat $USERS_DIR/${username}.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

    # Применение и одобрение CSR
    kubectl apply -f $USERS_DIR/${username}-csr.yaml
    kubectl certificate approve ${username}

    # Получение сертификата
    kubectl get csr ${username} -o jsonpath='{.status.certificate}' | base64 -d > $USERS_DIR/${username}.crt

    # Создание kubeconfig
    cat > $USERS_DIR/${username}-kubeconfig.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $(cat $USERS_DIR/ca.crt | base64 | tr -d '\n')
    server: $CLUSTER_SERVER
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    namespace: sales
    user: $username
  name: ${username}@${CLUSTER_NAME}
current-context: ${username}@${CLUSTER_NAME}
users:
- name: $username
  user:
    client-certificate-data: $(cat $USERS_DIR/${username}.crt | base64 | tr -d '\n')
    client-key-data: $(cat $USERS_DIR/${username}.key | base64 | tr -d '\n')
EOF

    log "✅ Пользователь $username создан"
}

# Создание пользователей
log "Создание пользователя sales-admin..."
create_user "sales-admin" "Администратор namespace sales"

log "Создание пользователя sales-developer..."
create_user "sales-developer" "Разработчик namespace sales"

# Создание инструкций
cat > $USERS_DIR/README.md <<EOF
# Созданные пользователи

## sales-admin
- **Роль**: Администратор namespace sales
- **Kubeconfig**: \`sales-admin-kubeconfig.yaml\`
- **Права**: Полный доступ к namespace sales

## sales-developer
- **Роль**: Разработчик namespace sales
- **Kubeconfig**: \`sales-developer-kubeconfig.yaml\`
- **Права**: Ограниченный доступ для разработки

## Использование

### Тестирование пользователя sales-admin:
\`\`\`bash
export KUBECONFIG=./users/sales-admin-kubeconfig.yaml
kubectl auth whoami
kubectl get pods -n sales
kubectl create deployment test-app --image=nginx -n sales
\`\`\`

### Тестирование пользователя sales-developer:
\`\`\`bash
export KUBECONFIG=./users/sales-developer-kubeconfig.yaml
kubectl auth whoami
kubectl get pods -n sales
kubectl create deployment test-dev --image=nginx -n sales
\`\`\`

### Проверка прав:
\`\`\`bash
# Для sales-admin
kubectl auth can-i "*" "*" -n sales

# Для sales-developer
kubectl auth can-i create deployments -n sales
kubectl auth can-i delete secrets -n sales
\`\`\`

## Очистка
\`\`\`bash
# Удаление CSR
kubectl delete csr sales-admin sales-developer

# Удаление тестовых приложений
kubectl delete deployment test-app test-dev -n sales
\`\`\`
EOF

log "🎉 Пользователи созданы успешно!"
warn "📝 Следующий шаг: выполните ./create-roles.sh"
warn "📄 Инструкции сохранены в: $USERS_DIR/README.md"
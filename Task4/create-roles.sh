#!/bin/bash

# Скрипт создания RBAC ролей для namespace sales
# Создает роли admin и developer

set -e

echo "🔐 Создание RBAC ролей для namespace sales"
echo "=========================================="

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

# Создание директории для ролей
ROLES_DIR="./roles"
mkdir -p $ROLES_DIR

log "Создание namespace sales..."
cat > $ROLES_DIR/namespace.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: sales
  labels:
    domain: sales
    company: propdevelopment
EOF

log "Создание роли sales-admin-role..."
cat > $ROLES_DIR/sales-admin-role.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: sales
  name: sales-admin-role
  labels:
    domain: sales
    role-type: admin
rules:
# Полный доступ ко всем ресурсам в namespace sales
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["extensions", "networking.k8s.io"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["autoscaling"]
  resources: ["*"]
  verbs: ["*"]
# Доступ к метрикам
- apiGroups: ["metrics.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list"]
EOF

log "Создание роли sales-developer-role..."
cat > $ROLES_DIR/sales-developer-role.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: sales
  name: sales-developer-role
  labels:
    domain: sales
    role-type: developer
rules:
# Управление приложениями
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
# Управление подами
- apiGroups: [""]
  resources: ["pods", "pods/log", "pods/exec"]
  verbs: ["get", "list", "watch", "create", "delete"]
# Управление сервисами
- apiGroups: [""]
  resources: ["services", "endpoints"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
# Управление конфигурациями (но НЕ секретами)
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
# Только ЧТЕНИЕ секретов (не создание/изменение)
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
# Просмотр событий
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "list", "watch"]
# Доступ к метрикам
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods"]
  verbs: ["get", "list"]
# Управление ingress
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF

log "Применение созданных ролей..."

# Применение манифестов
kubectl apply -f $ROLES_DIR/namespace.yaml
kubectl apply -f $ROLES_DIR/sales-admin-role.yaml
kubectl apply -f $ROLES_DIR/sales-developer-role.yaml

# Создание сводного файла
cat > $ROLES_DIR/roles-summary.md <<EOF
# RBAC Роли для namespace sales

## Созданные роли:

### 1. sales-admin-role (Role)
- **Область**: namespace sales
- **Права**: Полный доступ ко всем ресурсам в namespace
- **Может**: Создавать, изменять, удалять любые ресурсы в sales
- **Включает**: Доступ к секретам

### 2. sales-developer-role (Role)
- **Область**: namespace sales
- **Права**: Ограниченный доступ для разработки
- **Может**:
  - Управлять deployments, pods, services
  - Создавать configmaps
  - Читать секреты (но не изменять)
  - Управлять ingress и HPA
- **Не может**:
  - Создавать/изменять секреты
  - Изменять RBAC правила
  - Удалять namespace

## Файлы:
- \`namespace.yaml\` - Namespace sales
- \`sales-admin-role.yaml\` - Роль администратора
- \`sales-developer-role.yaml\` - Роль разработчика

## Проверка созданных ролей:
\`\`\`bash
# Просмотр ролей
kubectl get roles -n sales

# Детали ролей
kubectl describe role sales-admin-role -n sales
kubectl describe role sales-developer-role -n sales
\`\`\`

## Следующий шаг:
Выполните \`./bind-users-roles.sh\` для привязки пользователей к ролям.
EOF

log "🎉 Роли созданы успешно!"
warn "📝 Следующий шаг: выполните ./bind-users-roles.sh"
warn "📄 Сводка ролей сохранена в: $ROLES_DIR/roles-summary.md"

# Проверка созданных ролей
log "Проверка созданных ролей:"
kubectl get roles -n sales
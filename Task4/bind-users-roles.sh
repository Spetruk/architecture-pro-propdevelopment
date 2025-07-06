#!/bin/bash

# Скрипт привязки пользователей к ролям RBAC
# Создает RoleBinding и ClusterRoleBinding

set -e

echo "🔗 Привязка пользователей к ролям RBAC"
echo "======================================"

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

success() {
    echo -e "${BLUE}[SUCCESS]${NC} $1"
}

# Создание директории для привязок
BINDINGS_DIR="./bindings"
mkdir -p $BINDINGS_DIR

log "Создание RoleBinding для sales-admin..."
cat > $BINDINGS_DIR/sales-admin-binding.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sales-admin-binding
  namespace: sales
  labels:
    domain: sales
    role-type: admin
subjects:
- kind: User
  name: sales-admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: sales-admin-role
  apiGroup: rbac.authorization.k8s.io
EOF

log "Создание RoleBinding для sales-developer..."
cat > $BINDINGS_DIR/sales-developer-binding.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sales-developer-binding
  namespace: sales
  labels:
    domain: sales
    role-type: developer
subjects:
- kind: User
  name: sales-developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: sales-developer-role
  apiGroup: rbac.authorization.k8s.io
EOF

log "Применение привязок ролей..."

# Применение всех привязок
kubectl apply -f $BINDINGS_DIR/sales-admin-binding.yaml
kubectl apply -f $BINDINGS_DIR/sales-developer-binding.yaml

# Создание сводного файла
cat > $BINDINGS_DIR/bindings-summary.md <<EOF
# Привязки пользователей к ролям

## Созданные привязки:

### RoleBindings (в namespace sales):
| Пользователь | Роль | Права |
|-------------|------|-------|
| \`sales-admin\` | \`sales-admin-role\` | Полный доступ к namespace sales |
| \`sales-developer\` | \`sales-developer-role\` | Ограниченный доступ для разработки |

## Матрица доступа:

| Действие | sales-admin | sales-developer |
|----------|-------------|-----------------|
| Создать deployment в sales | ✅ | ✅ |
| Удалить deployment в sales | ✅ | ✅ |
| Создать secret в sales | ✅ | ❌ |
| Читать secret в sales | ✅ | ✅ |
| Создать configmap в sales | ✅ | ✅ |
| Просмотр pods в sales | ✅ | ✅ |
| Просмотр logs в sales | ✅ | ✅ |
| Удалить namespace sales | ❌ | ❌ |
| Доступ к другим namespace | ❌ | ❌ |

## Файлы:
- \`sales-admin-binding.yaml\` - Привязка администратора
- \`sales-developer-binding.yaml\` - Привязка разработчика

## Проверка привязок:
\`\`\`bash
# Просмотр RoleBindings
kubectl get rolebindings -n sales

# Детали привязки
kubectl describe rolebinding sales-admin-binding -n sales
\`\`\`


# Ручное тестирование
export KUBECONFIG=./users/sales-admin-kubeconfig.yaml
kubectl get pods -n sales
kubectl create deployment test --image=nginx -n sales

export KUBECONFIG=./users/sales-developer-kubeconfig.yaml
kubectl get pods -n sales
kubectl create secret generic test --from-literal=key=value -n sales  # Должно быть запрещено
\`\`\`
EOF

log "🎉 Привязки созданы успешно!"
success "✅ RBAC настройка завершена!"

echo ""
warn "📄 Сводка привязок сохранена в: $BINDINGS_DIR/bindings-summary.md"

# Показать созданные привязки
log "Созданные привязки:"
kubectl get rolebindings -n sales
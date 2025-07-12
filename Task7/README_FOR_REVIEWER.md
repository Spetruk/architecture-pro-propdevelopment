
# Создать namespace с PodSecurity
kubectl apply -f 01-create-namespace.yaml

# Установить OPA Gatekeeper (если не установлен)
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

# Применить constraint templates
kubectl apply -f gatekeeper/constraint-templates/

# Применить constraints
kubectl apply -f gatekeeper/constraints/
2. Проверка блокировки небезопасных подов
bash# Эти команды должны ЗАВЕРШИТЬСЯ ОШИБКОЙ
kubectl apply -f insecure-manifests/01-privileged-pod.yaml --dry-run=server
kubectl apply -f insecure-manifests/02-hostpath-pod.yaml --dry-run=server
kubectl apply -f insecure-manifests/03-root-user-pod.yaml --dry-run=server
3. Проверка принятия безопасных подов
bash# Эти команды должны ЗАВЕРШИТЬСЯ УСПЕШНО
kubectl apply -f secure-manifests/01-secure.yaml --dry-run=server
kubectl apply -f secure-manifests/02-secure.yaml --dry-run=server
kubectl apply -f secure-manifests/03-secure.yaml --dry-run=server
4. Автоматическая проверка
bash# Сделать скрипты исполняемыми
chmod +x verify/verify-admission.sh
chmod +x verify/validate-security.sh

# Запустить проверку
./verify/verify-admission.sh
./verify/validate-security.sh


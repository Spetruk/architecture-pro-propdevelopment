


minikube delete
minikube start

sudo mkdir -p /etc/kubernetes/
sudo cp "audit-policy.yaml" /etc/kubernetes/audit-policy.yaml # сюда закидываю чтобы sh similate-incedent.sh отработал, он ожидает найти файл по такому пути
minikube cp "audit-policy.yaml" /etc/kubernetes/audit-policy.yaml #закиываем его в работающий minikube
minikube cp kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml #тут прописаны команды запуска аудита и volumes для логов + аудит файла (эти volumes внутри minikube для pod'ов а не во вне (локальную тачку) - kube-apiservice работает из пода и ему над откуда-то данные брать/хранить)
minikube start #перезапускаем minikube где применятся параметры аудита из kube-apiserver.yaml
sh simulate-incedent.sh
rm ~/Developer/architecture-pro-propdevelopment/Task6/scripts/audit.log
minikube ssh "sudo cat /var/log/audit.log" > ~/Developer/architecture-pro-propdevelopment/Task6/scripts/audit.log


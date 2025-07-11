minikube delete
minikube start
minikube cp ~/etc/kubernetes/audit-policy.yaml /etc/kubernetes/audit-policy.yaml
#minikube cp ~/var/log/audit.log /var/log/audit.log
minikube cp kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml
minikube start
#cp "audit-policy.yaml" /Users/av/etc/kubernetes/audit-policy.yaml

#mkdir -p ~/.minikube/files/etc/kubernetes/
#cp "audit-policy.yaml" ~/.minikube/files/etc/kubernetes/audit-policy.yaml


#minikube cp ~/.minikube/files/etc/kubernetes/audit-policy.yaml /etc/kubernetes/audit-policy.yaml
#minikube start

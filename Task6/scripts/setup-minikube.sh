minikube delete
minikube start
mkdir -p ~/.minikube/files/etc/kubernetes/
cp "audit-policy.yaml" ~/.minikube/files/etc/kubernetes/audit-policy.yaml

sudo minikube cp kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml
minikube start

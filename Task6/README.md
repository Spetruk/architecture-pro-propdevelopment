


minikube start --driver=qemu2 --kubernetes-version=v1.33.1 \  
--extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit-policy.yaml \
--extra-config=apiserver.audit-log-path=/var/lib/minikube/audit.log \
--extra-config=apiserver.audit-log-format=json \
--extra-config=apiserver.audit-log-maxage=30 \
--extra-config=apiserver.audit-log-maxbackup=10 \
--extra-config=apiserver.audit-log-maxsize=100 \
--mount \
--mount-string="/Users/av/Developer/architecture-pro-propdevelopment/Task6/audit-policy.yaml:/etc/kubernetes/audit-policy.yaml"
--dns=8.8.8.8

minikube start --driver=qemu2 --kubernetes-version=v1.33.1 \
--network socket_vmnet \
--alsologtostderr=true \
--extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit-policy.yaml \
--extra-config=apiserver.audit-log-path=/var/lib/minikube/audit.log \
--extra-config=apiserver.audit-log-format=json \
--extra-config=apiserver.audit-log-maxage=30 \
--extra-config=apiserver.audit-log-maxbackup=10 \
--extra-config=apiserver.audit-log-maxsize=100 \
--mount \
--mount-string="/Users/av/Developer/architecture-pro-propdevelopment/Task6/audit-policy.yaml:/etc/kubernetes/audit-policy.yaml"


1:1       warning  missing document start "---"  (document-start)
5:81      error    line too long (86 > 80 characters)  (line-length)
14:3      error    wrong indentation: expected 4 but found 2  (indentation)
15:5      error    wrong indentation: expected 6 but found 4  (indentation)
83:5      error    wrong indentation: expected 6 but found 4  (indentation)
107:3     error    wrong indentation: expected 4 but found 2  (indentation)
111:6     error    wrong indentation: expected 6 but found 5  (indentation)
113:2     error    syntax error: expected <block end>, but found '<block mapping start>' (syntax)
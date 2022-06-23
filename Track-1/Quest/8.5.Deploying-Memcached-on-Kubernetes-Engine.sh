curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

gcloud container clusters create demo-cluster --num-nodes 3 --zone us-central1-f
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install mycache stable/memcached --set replicaCount=3
kubectl get pods

completed "Task 1"

kubectl get service mycache-memcached -o jsonpath="{.spec.clusterIP}" ; echo
kubectl get endpoints mycache-memcached
kubectl run -it --rm alpine --image=alpine:3.6 --restart=Never nslookup mycache-memcached.default.svc.cluster.local



helm delete mycache
helm install mycache stable/mcrouter --set memcached.replicaCount=3
kubectl get pods

completed "Task 2"

MCROUTER_POD_IP=$(kubectl get pods -l app=mycache-mcrouter -o jsonpath="{.items[0].status.podIP}")

cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-application-py
spec:
  replicas: 5
  selector:
    matchLabels:
      app: sample-application-py
  template:
    metadata:
      labels:
        app: sample-application-py
    spec:
      containers:
        - name: python
          image: python:3.6-alpine
          command: [ "sh", "-c"]
          args:
          - while true; do sleep 10; done;
          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
EOF
kubectl get pods

completed "Task 3"

POD=$(kubectl get pods -l app=sample-application-py -o jsonpath="{.items[0].metadata.name}")
kubectl exec -it $POD -- sh -c 'echo $NODE_NAME'
kubectl run -it --rm alpine --image=alpine:3.6 --restart=Never telnet gke-demo-cluster-default-pool-XXXXXXXX-XXXX 5000

warning "Wait for some moment to get the marks"

completed "Lab"

remove_files 

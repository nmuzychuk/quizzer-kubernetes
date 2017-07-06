#!/bin/bash

### Create test kubernetes cluster ###

# Install docker, kubelet, kubectl, kubeadm
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker-engine
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# Initialize master
kubeadm init

export KUBECONFIG=/etc/kubernetes/admin.conf

# Install a pod network
kubectl apply -f https://git.io/weave-kube-1.6

# Enable scheduling pods on the master
kubectl taint nodes --all node-role.kubernetes.io/master-

### Deploy app components ###

# Deploy PostgreSQL
kubectl apply -f postgres-deployment.yaml

# Build app docker image
QUIZZER_REPO=https://github.com/nmuzychuk/quizzer.git
docker build -t quizzer ${QUIZZER_REPO}

# Upload secrets
SECRET_KEY_BASE=$(date | sha256sum | cut -d' ' -f1)
DATABASE_URL=postgresql://postgres@postgres/quizzer_production

kubectl create secret generic quizzer \
  --from-literal=secret_key_base="${SECRET_KEY_BASE}" \
  --from-literal=database_url="${DATABASE_URL}"

# Deploy app
kubectl apply -f quizzer-deployment.yaml

# Expose
kubectl expose deployment quizzer --type=NodePort

sleep 30

# Verify
NODE_PORT=$(kubectl describe svc quizzer | grep NodePort: | cut -d$'\t' -f4 | cut -d'/' -f1)
curl localhost:"${NODE_PORT}" | grep "Play Quizzes"

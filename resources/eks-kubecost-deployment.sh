#!/bin/bash
: "${DOMAIN_NAME:=$1}"
: "${KUBECOST_TOKEN:=$2}"

#USAGE_PROMPT="Use: $0 <STACKNAME> <DOMAINNAME>\n
#Example: $0 test-stack mydomain.com"


if [[ -z ${DOMAIN_NAME} ]]; then
  echo "Domain Name was not provided."
  echo -e $USAGE_PROMPT
  exit 2
fi

if [[ -z ${KUBECOST_TOKEN} ]]; then
  echo "Kubecost Token was not provided."
  echo -e $USAGE_PROMPT
  exit 2
fi

EKS_REF_ROOT_DIR=$(pwd)
export AWS_DEFAULT_REGION=$AWS_REGION

echo "Install Helm Kubecost"
cd resources/templates
kubectl create namespace kubecost
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="$KUBECOSTTOKEN"
sed -i 's,DOMAIN_NAME,'$DOMAIN_NAME',g' eks-kubecost-ingress.yaml
kubectl apply -f eks-kubecost-ingress.yaml -n kubecost
echo "Provide Kubecost Password"
htpasswd -c auth kubecost-admin
kubectl create secret generic kubecost-auth --from-file auth -n kubecost

//Sleep - to wait ext-dns creates A record
sleep 180

echo "Kubecost deployment complete!!"
# Prerequisites

This repo supports blue green infrastructure deploys and preview versions of Azure Kubernetes Service.

```sh
# install tools
brew update
brew install azure-cli terraform jq yq
az login

# enable preview extensions in cli
az extension add --name aks-preview
az extension update --name aks-preview

# [enable the AKS-managed Azure AD preview feature in your Subscription](https://docs.microsoft.com/en-us/azure/aks/managed-aad)
az feature register --name AAD-V2 --namespace Microsoft.ContainerService
while [ "$(az feature register --name AAD-V2 --namespace Microsoft.ContainerService | jq .properties.state -r)" != "Registered" ]; do sleep 1; done

# finally, refresh the registration of the resource provider
az provider register --namespace Microsoft.ContainerService

# if you don't have a public/private ssh key pair, create one
ssh-keygen

# create a main.tf file
echo -n "module \"aks-appgw-fe\" {
  source  = \"richminchukio/aks-appgw-fe/azurerm\"
  version = \"0.2.0\"
  
  ssh_public_key = file(\"~/.ssh/id_rsa.pub\")
}" >./main.tf
```

# terraform plan/apply

Run all of the below each time you want to plan/apply changes (changes like: a bump in the version of this module).

```sh
# SETUP TF_VARS
export TF_VAR_blue_green=blue # blue or green. you decide
export TF_VAR_infra_prefix=tf_${RANDOM} # you should replace this with something not random
export TF_VAR_location=eastus # where do you want your aks/appgw deployed

# SENSIBLE DEFAULTS - override when necessary
export TF_VAR_helm_aad_pod_identity_version=4.1.3
export TF_VAR_helm_cert_manager_version=v1.4.2
export TF_VAR_helm_ingress_azure_version=1.2.1
export TF_VAR_k8s_version=$(az aks get-versions --location $TF_VAR_location --output yaml | yq e '.orchestrators[].orchestratorVersion' - | tail -n 1) 
# always try to use the latest version of kubernetes available in your region. ^^^^^^ https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions#azure-portal-and-cli-versions

# INIT - initialize the terraform repo locally and clean up the terraform providers
rm -rf .terraform # it's best to wipe this folder out each time before init-ing, and before each terraform plan command.
terraform init -backend-config="key=$TF_VAR_blue_green.tfstate"

# AKS CLI AND .KUBE/CONFIG - always try to setup the kube config before we plan/apply anything. IE: Helm chart terraform resources may fail to deploy if you don't have your kube config set up. You'll likely want to run this each time before you terraform plan/apply.
az aks install-cli \
   --client-version ${TF_VAR_k8s_version} 2>/dev/null
az aks get-credentials \
   --resource-group ${TF_VAR_infra_prefix}_rg_${TF_VAR_blue_green} \
   --name ${TF_VAR_infra_prefix}_aks_${TF_VAR_blue_green} \
   --overwrite-existing \
   --admin 2>/dev/null
kubectl config use-context ${TF_VAR_infra_prefix}_aks_${TF_VAR_blue_green}-admin 2>/dev/null

# PLAN - plan the deployment
terraform plan -out "plan.$TF_VAR_blue_green.tfplan"

# APPLY - build the proposed blue or green infrastructure
terraform apply "plan.$TF_VAR_blue_green.tfplan"
```

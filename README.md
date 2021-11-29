# Prerequisites

This repo supports blue green infrastructure deploys and preview versions of Azure Kubernetes Service.

## macos zsh setup

```zsh
# install tools
brew update
brew install azure-cli terraform helm jq yq
az login

# pull the richminchukio helm repo, so we can find the latest version.
helm repo add richminchukio https://raw.githubusercontent.com/richminchukio/helm-aks-appgw-fe/master
helm repo update

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
echo "
module \"aks-appgw-fe\" {
  source  = \"richminchukio/aks-appgw-fe/azurerm\"
  version = \"1.0.0\"
  
  blue_green                = var.blue_green
  helm_aks_appgw_fe_version = var.helm_aks_appgw_fe_version
  infra_prefix              = var.infra_prefix
  k8s_version               = var.k8s_version
  location                  = var.location
  ssh_public_key            = file(\"~/.ssh/id_rsa.pub\")
}" >./main.tf
```

## SETUP variables.tf.json

```zsh
echo "{
   \"variable\": {
      \"blue_green\": {
         \"default\": \"blue\"
      },
      \"helm_aks_appgw_fe_version\": {
         \"default\": \"$(helm show chart richminchukio/aks-appgw-fe --version=\<2 | yq eval '.version' -)\"
      },
      \"infra_prefix\": {
         \"default\": \"tf_${RANDOM}\"
      },
      \"k8s_version\": {
         \"default\": \"$(az aks get-versions --location eastus --output yaml | yq eval '.orchestrators[].orchestratorVersion' - | tail -n 1)\"
      },
      \"location\": {
         \"default\": \"eastus\"
      }
   }
}" >./variables.tf.json
```

## terraform plan/apply

Run all of the below each time you want to plan/apply changes (changes like: a bump in the version of this module, or blue/green).

```sh
# get useful variables out of our terraform variables.tf.json file.
export blue_green=$(cat variables.tf.json | jq -r .Variable.blue_green.default)
export k8s_version=$(cat variables.tf.json | jq -r .Variable.k8s_version.default)
export infra_prefix=$(cat variables.tf.json | jq -r .Variable.infra_prefix.default)

# INIT - initialize the terraform repo locally and clean up the terraform providers
rm -rf .terraform # it's best to wipe this folder out each time before init-ing, and before each terraform plan command.
terraform init -backend-config="key=$blue_green.tfstate"

# AKS CLI AND .KUBE/CONFIG - always try to setup the kube config before we plan/apply anything. IE: Helm chart terraform resources may fail to deploy if you don't have your kube config set up. You'll likely want to run this each time before you terraform plan/apply.
az aks install-cli \
   --client-version $k8s_version 2>/dev/null
az aks get-credentials \
   --resource-group ${infra_prefix}_rg_${blue_green} \
   --name ${infra_prefix}_aks_${blue_green} \
   --overwrite-existing \
   --admin 2>/dev/null
kubectl config use-context ${infra_prefix}_aks_${blue_green}-admin 2>/dev/null

# PLAN - plan the deployment
terraform plan -out "plan.tfplan"

# APPLY - build the proposed blue or green infrastructure
terraform apply "plan.tfplan"
```

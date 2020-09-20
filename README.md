# USING THIS REPO

This repo supports blue green deploys.

```sh
# install tools
brew update
brew install azure-cli terraform jq
az login

# enable preview extensions in cli
az extension add --name aks-preview
az extension update --name aks-preview

# [enable the AKS-managed Azure AD preview feature in your Subscription](https://docs.microsoft.com/en-us/azure/aks/managed-aad)
az feature register --name AAD-V2 --namespace Microsoft.ContainerService
while [ "$(az feature register --name AAD-V2 --namespace Microsoft.ContainerService | jq .properties.state -r)" != "Registered" ]; do sleep 1; done

# finally, refresh the registration of the resource provider
az provider register --namespace Microsoft.ContainerService

# SETUP TF_VARS 
export TF_VAR_blue_green=blue
export TF_VAR_infra_prefix=tf_${RANDOM}
export TF_VAR_location=eastus
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)

# SENSIBLE DEFAULTS
export TF_VAR_helm_aad_pod_identity_version=2.0.2
export TF_VAR_helm_ingress_azure_version=1.2.0
export TF_VAR_helm_cert_manager_version=v1.0.1
export TF_VAR_k8s_version=1.18.6

# use the module
echo -n "variable \"ssh_public_key\" {}

module \"aks-appgw-fe\" {
  source  = \"richminchukio/aks-appgw-fe/azurerm\"
  version = \"0.1.0\"
  
  ssh_public_key = var.ssh_public_key
}"

# initialize the terraform repo locally
rm -rf .terraform
terraform init \
   -backend-config="key=$TF_VAR_blue_green.tfstate"

# always try to setup the kube config before we plan/apply anything
az aks install-cli \
   --client-version ${TF_VAR_k8s_version} 2>/dev/null
az aks get-credentials \
   --resource-group ${TF_VAR_infra_prefix}_rg_${TF_VAR_blue_green} \
   --name ${TF_VAR_infra_prefix}_aks_${TF_VAR_blue_green} \
   --overwrite-existing \
   --admin 2>/dev/null
kubectl config use-context ${TF_VAR_infra_prefix}_aks_${TF_VAR_blue_green}-admin 2>/dev/null

# plan the deployment
terraform plan \
   -out "plan.$TF_VAR_blue_green.tfplan"

# build the proposed blue or green infrastructure
terraform apply \
   "plan.$TF_VAR_blue_green.tfplan"

# clean up the terraform providers
rm -rf .terraform
```
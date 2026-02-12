
myResourceGroup="mohit-master" 
location="swedencentral" 

DNS_NAME_LABEL=aci-example-qazxswedc

az container create --resource-group $myResourceGroup \
    --name mycontainer \
    --image mcr.microsoft.com/azuredocs/aci-helloworld \
    --ports 80 \
    --dns-name-label $DNS_NAME_LABEL --location $location \
    --os-type Linux \
    --cpu 1 \
    --memory 1.5 


az container show --resource-group $myResourceGroup \
    --name mycontainer \
    --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" \
    --out table 
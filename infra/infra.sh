#!/bin/bash
# asdf

# activate debugging from here
set -x

# generate a random suffix between 1 and 1000
int=$(shuf -i 1-1000 -n 1)
# Password must have the 3 of the following: 1 lower case character, 1 upper case character, 1 number and 1 special character
# generate a 34 character password (normal, capitals and numbers)
password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c34)

rg=WebApplication5TEST${int}
dnsname=webapplication5test${int}
adminusername=azureuser${int}
adminpassword=${password}

region=westeurope
vmname=webapplication5test${int}
vnet=vnet${int}
subnet=subnet${int}
publicIPName=publicIP${int}
nsgname=nsg${int}
nicName=nic${int}
# use current LTS Version of Ubuntu - 18.04.3 as of 8th Nov 2019
image=UbuntuLTS

# Create a resource group
az group create \
   --name ${rg} \
   --location ${region}

# Create a virtual network
az network vnet create \
    --resource-group ${rg} \
    --name ${vnet} \
    --subnet-name ${subnet} 

# Create a network with a public IP and associate with the given DNS name
az network public-ip create \
    --resource-group ${rg} \
    --name ${publicIPName} \
    --dns-name ${dnsname}
    #--allocation-method Static \

# Create a nework security group
az network nsg create \
    --resource-group ${rg} \
    --name ${nsgname}

# allow port 22 ssh
az network nsg rule create \
    --resource-group ${rg} \
    --nsg-name ${nsgname} \
    --name nsgGroupRuleSSH \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

# allow port 80
az network nsg rule create \
    --resource-group ${rg} \
    --nsg-name ${nsgname} \
    --name nsgGroupRuleWeb80 \
    --protocol tcp \
    --priority 1001 \
    --destination-port-range 80 \
    --access allow

# allow port 443
az network nsg rule create \
    --resource-group ${rg} \
    --nsg-name ${nsgname} \
    --name nsgGroupRuleWeb443 \
    --protocol tcp \
    --priority 1002 \
    --destination-port-range 443 \
    --access allow

# Create a virtual network card and associate with publicIP address and NSG
az network nic create \
    --resource-group ${rg} \
    --name ${nicName} \
    --vnet-name ${vnet} \
    --subnet ${subnet} \
    --public-ip-address ${publicIPName} \
    --network-security-group ${nsgname}

# Create vm which runs the cloud init script to provision apache, php etc
# Standard_DS1_v2 is the default
# az vm list-sizes
# https://azure.microsoft.com/en-gb/pricing/details/virtual-machines/linux/
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general

az vm create \
    --resource-group ${rg} \
    --name ${vmname} \
    --location ${region} \
    --nics ${nicName} \
    --image ${image} \
    --ssh-key-values sshkey-homelenovo.pub sshkey-work.pub sshkey-homedesktop.pub \
    --custom-data cloud-init.txt \
    --size Standard_B2s
    # --size Standard_D2s_v3
    # --size Standard_B1ms
    # --generate-ssh-keys \
# --admin-username ${adminusername} \
#    --admin-password ${adminpassword} \
    # --size Standard_DS1_v2
    # --size Standard_B1ms

# -o is skip are you sure about ssh keys
echo -e "\nssh -o StrictHostKeyChecking=no dave@${dnsname}.westeurope.cloudapp.azure.com\n"

## FortiGate-VM (BYOL/PAYG) HA SDN connector cluster on Azure with 3 ports

A Terraform script to deploy a FortiGate-VM Cluster on Azure using a SDN connector HA topology

## Introduction
This topology is only recommended for using with FOS 7.0.5 and later which supports 3 port HA setup combining HA reserved management ports and sync into the same interfaces.
* port1 - hamgmt/hasync with public IP
* port2 - public/untrust with public IP
* port3 - private/trust

This terraform script supports both availability zones and availablity sets with a variable toggle.

## Requirements

* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 0.12.0
* Terraform Provider AzureRM >= 2.24.0
* Terraform Provider Template >= 2.2.0
* Terraform Provider Random >= 3.1.0

## Deployment overview
Terraform deploys the following components:

* Azure Virtual Network with 4 subnets - external, internal, 2x workload subnets
* 2x FortiGate-VM (BYOL/PAYG) instances with three NICs.  Each FortiGate-VM reside in different availability zones.
* Untrust interface placed in SD-WAN zone "Underlay".
* 2x firewall rules - permit outbound, and permit internal.
* Azure SDN connector using managed identity with reader and network contributor roles. The latter is utilised for SDN connector based HA failover. 
* 2x Ubuntu 20.04 LTS test client VMs in each workload subnet.
* UDRs for internal subnet routing table for default routing and inter-subnet routing through active FortiGate (HA is orchestrated by SDN connector)
* Choose PAYG or BYOL in variables - if BYOL, place .lic files in subfolder "licenses" and define in variables.
* Choose availability zone or availability set using the availability_zone boolean variable (false will use availability set).
* Terraform backend (versions.tf) stored in Azure storage - customise backend.conf to suit or modify as appropriate. An backend.conf.example is provided  or comment out the backend "azurerm" resource block to use the default local backend for example.

**If availability_zone is set to true, then region must support this feature. If availability_zone is set to false, then the deployment will be performed using an availability set with 2 domains.**

**Topology using default variables**

![img](https://github.com/wintermute000/azure-fgt-sdn-ha-crosszone-3port/blob/main/azure-fgt-sdn-ha-crosszone-3port.jpg)

For a detailed walkthrough of the operation of this topology, refer to https://github.com/40net-cloud/fortinet-azure-solutions/tree/main/FortiGate/Active-Passive-SDN

## Deployment

To deploy the FortiGate-VM to Azure:
1. Clone the repository.
2. Customize variables defined in `variables.tf` file as needed with a standard *.auto.tfvars file. An example is provided.
3. Initialize the providers defining the backend (terraform init -backend-config=backend.conf) and run terraform as normal.

Outputs:

- ActiveMGMTPublicIP = <Active FGT Management Public IP>
- ClusterPublicIP = <Cluster Public IP>
- PassiveMGMTPublicIP = <Passive FGT Management Public IP>
- Password = <FGT Password>
- ResourceGroup = <Resource Group>
- Username = <FGT admin>
- VNET_CIDR = <vnet summary route>

Azure credentials:

The following code is commented out in provider.tf that can be uncommented to run via a service principal

- subscription_id = var.subscription_id
- client_id       = var.client_id
- client_certificate_path   = var.client_certificate_path
- tenant_id       = var.tenant_id

The client_id and client_certificate_path variables are only required for this purpose.

## Acknowledgements
This template was developed from the starting point of https://github.com/fortinet/fortigate-terraform-deploy/tree/main/azure/7.2/ha-port1-mgmt-crosszone-3ports and then enhanced with availability zone / availablity set selection, managed identity SDN connector etc.
References to custom images are commented out. 

## Support
Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/fortinet/fortigate-terraform-deploy/issues) tab of this GitHub project.
For other questions related to this project, contact [github@fortinet.com](mailto:github@fortinet.com).

## License
[License](https://github.com/fortinet/fortigate-terraform-deploy/blob/master/LICENSE) © Fortinet Technologies. All rights reserved.
# 

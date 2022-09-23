// Azure configuration
variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_certificate_path" {
  type = string
}

variable "tenant_id" {
  type = string
}

//  For HA, choose instance size that support 4 nics at least
//  Check : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes
variable "size" {
  type    = string
  default = "Standard_F4"
}

variable "client_size" {
  type    = string
  default = "Standard_B1s"
}

// If availablity zone false, then availability set is used
variable "availability_zone" {
  type    = bool
  default = true
}

// Availability zones only support in certain regions
// Check: https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
variable "zone1" {
  type    = string
  default = "1"
}

variable "zone2" {
  type    = string
  default = "2"
}

variable "location" {
  type    = string
  default = "australiaeast"
}

variable "vnetname" {
  type    = string
  default = "azhublb-vnet"
}

variable "rgname" {
  type    = string
  default = "azhublb-rg"
}

variable "activename" {
  type    = string
  default = "azhubsdn-fgt1"
}

variable "passivename" {
  type    = string
  default = "azhubsdn-fgt2"
}

variable "publicsubnetname" {
  type    = string
  default = "ext-subnet"
}

variable "private1subnetname" {
  type    = string
  default = "int-subnet"
}

variable "private2subnetname" {
  type    = string
  default = "workload1-subnet"
}

variable "private3subnetname" {
  type    = string
  default = "workload2-subnet"
}

variable "hamgmtsubnetname" {
  type    = string
  default = "hamgmt-subnet"
}

variable "clusterpip1name" {
  type    = string
  default = "cluster1-pip"
}

variable "activepipname" {
  type    = string
  default = "active-mgmt-pip"
}

variable "passivepipname" {
  type    = string
  default = "passive-mgmt-pip"
}

variable "sdnrolename" {
  type    = string
  default = "fgt-sdn-connector-role"
}

variable "client1name" {
  type    = string
  default = "azhublb-client1"
}

variable "client2name" {
  type    = string
  default = "azhublb-client2"
}

// To use custom image uncomment relevant sections in active.tf and passive.tf
// by default is false
variable "custom" {
  default = false
}

//  Custom image blob uri
variable "customuri" {
  type    = string
  default = "<custom image blob uri>"
}

variable "custom_image_name" {
  type    = string
  default = "<custom image name>"
}

variable "custom_image_resource_group_name" {
  type    = string
  default = "<custom image resource group>"
}

// License Type to create FortiGate-VMs
// Provide the license type for FortiGate-VM Instances, either byol or payg.
// If byol the fourth static route (for vnet summary) is not automatically created due to inherent FortiOS limitation before licensing.
// If byol then either supply license filename (in "licenses" subdir) or flex-vm token, DO NOT populate variable if not using
variable "license_type" {
  default = "payg"
}

// enable accelerate network, either true or false, default is false
// Make the the instance choosed supports accelerated networking.
// Check: https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview#supported-vm-instances
variable "accelerate" {
  default = "true"
}

variable "publisher" {
  type    = string
  default = "fortinet"
}

variable "fgtoffer" {
  type    = string
  default = "fortinet_fortigate-vm_v5"
}

// BYOL sku: fortinet_fg-vm
// PAYG sku: fortinet_fg-vm_payg_2022
variable "fgtsku" {
  type = map(any)
  default = {
    byol = "fortinet_fg-vm"
    payg = "fortinet_fg-vm_payg_2022"
  }
}

// FOS version
variable "fgtversion" {
  type    = string
  default = "7.2.1"
}

variable "adminusername" {
  type    = string
  default = "fortiuser"
}

variable "adminpassword" {
  type    = string
  default = "SecurityFabric1!"
}

// HTTPS Port
variable "adminsport" {
  type    = string
  default = "8443"
}

variable "sshport" {
  type    = string
  default = "2222"
}

variable "vnetcidr" {
  default = "172.30.0.0/16"
}

variable "publiccidr" {
  default = "172.30.0.0/24"
}

variable "private1cidr" {
  default = "172.30.1.0/24"
}

variable "private2cidr" {
  default = "172.30.2.0/24"
}

variable "private3cidr" {
  default = "172.30.3.0/24"
}

variable "hasynccidr" {
  default = "172.30.254.0/24"
}

variable "hamgmtcidr" {
  default = "172.30.255.0/24"
}

variable "activeport1" {
  default = "172.30.255.10"
}

variable "activeport1mask" {
  default = "255.255.255.0"
}

variable "activeport2" {
  default = "172.30.0.10"
}

variable "activeport2mask" {
  default = "255.255.255.0"
}

variable "activeport3" {
  default = "172.30.1.10"
}

variable "activeport3mask" {
  default = "255.255.255.0"
}


variable "passiveport1" {
  default = "172.30.255.11"
}

variable "passiveport1mask" {
  default = "255.255.255.0"
}

variable "passiveport2" {
  default = "172.30.0.11"
}

variable "passiveport2mask" {
  default = "255.255.255.0"
}

variable "passiveport3" {
  default = "172.30.1.11"
}

variable "passiveport3mask" {
  default = "255.255.255.0"
}

variable "port1gateway" {
  default = "172.30.255.1"
}

variable "port2gateway" {
  default = "172.30.0.1"
}

variable "port3gateway" {
  default = "172.30.1.1"
}

variable "intlbaddress" {
  default = "172.30.1.4"
}

variable "bootstrap-active" {
  // Change to your own path
  type    = string
  default = "config-active.conf"
}

variable "bootstrap-passive" {
  // Change to your own path
  type    = string
  default = "config-passive.conf"
}


// license file for the active fgt IF using byol and supplying license file in "licenses" subdir - DO NOT populate if using flex
variable "fgtlicense" {
  // Change to your own byol license file, license.lic
  type    = string
  default = ""
}

// license file for the passive fgt IF using byol and supplying license file in "licenses" subdir - DO NOT populate if using flex
variable "fgtlicense2" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = ""
}

// Flex token for the active fgt IF using byol and using flex - DO NOT populate if supplying .lic file instead
variable "fgtflextoken" {
  // Change to your own Flex-VM token. 
  type    = string
  default = ""
}

// Flex token for the passive fgt IF using byol and using flex - DO NOT populate if supplying .lic file instead
variable "fgtflextoken2" {
  // Change to your own Flex-VM token. 
  type    = string
  default = ""
}


variable "tags" {
  type = map(any)
  default = {
    environment = "dev"
  }
}

variable "publicnsg" {
  type = map(map(string))
  default = {
    i100 = {
      name                       = "ingress"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    e100 = {
      name                       = "egress"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

variable "privatensg" {
  type = map(map(string))
  default = {
    i100 = {
      name                       = "ingress"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    e100 = {
      name                       = "egress"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
// Create Virtual Network

resource "azurerm_virtual_network" "fgtvnetwork" {
  name                = var.vnetname
  address_space       = [var.vnetcidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = local.common_tags
}

resource "azurerm_subnet" "publicsubnet" {
  name                 = var.publicsubnetname
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.publiccidr]
}

resource "azurerm_subnet" "private1subnet" {
  name                 = var.private1subnetname
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.private1cidr]

}

resource "azurerm_subnet" "private2subnet" {
  name                 = var.private2subnetname
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.private2cidr]
}

resource "azurerm_subnet" "private3subnet" {
  name                 = var.private3subnetname
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.private3cidr]
}


resource "azurerm_subnet" "hamgmtsubnet" {
  name                 = var.hamgmtsubnetname
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.hamgmtcidr]
}

// Allocated Public IP
resource "azurerm_public_ip" "ClusterPublicIP" {
  name                = var.clusterpip1name
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = local.common_tags
}

resource "azurerm_public_ip" "ActiveMGMTIP" {
  name                = var.activepipname
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = local.common_tags
}

resource "azurerm_public_ip" "PassiveMGMTIP" {
  name                = var.passivepipname
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = local.common_tags
}

//  Network Security Group
resource "azurerm_network_security_group" "publicnetworknsg" {
  name                = "PublicNetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
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

  security_rule {
    name                        = "egress"
    priority                    = 100
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }


  tags = local.common_tags
}

resource "azurerm_network_security_group" "privatenetworknsg" {
  name                = "PrivateNetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
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

  security_rule {
    name                        = "egress"
    priority                    = 100
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }

  tags = local.common_tags
}


// Active FGT Network Interface port1
resource "azurerm_network_interface" "activeport1" {
  name                          = "${var.activename}-port1"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hamgmtsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.activeport1
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.ActiveMGMTIP.id
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "activeport2" {
  name                          = "${var.activename}-port2"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.publicsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.activeport2
    public_ip_address_id = azurerm_public_ip.ClusterPublicIP.id
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "activeport3" {
  name                          = "${var.activename}-port3"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.private1subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.activeport3
  }

  tags = local.common_tags
}

# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "port1nsg" {
  depends_on                = [azurerm_network_interface.activeport1]
  network_interface_id      = azurerm_network_interface.activeport1.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "port2nsg" {
  depends_on                = [azurerm_network_interface.activeport2]
  network_interface_id      = azurerm_network_interface.activeport2.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "port3nsg" {
  depends_on                = [azurerm_network_interface.activeport3]
  network_interface_id      = azurerm_network_interface.activeport3.id
  network_security_group_id = azurerm_network_security_group.privatenetworknsg.id
}

// Passive FGT Network Interface port1
resource "azurerm_network_interface" "passiveport1" {
  name                          = "${var.passivename}-port1"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hamgmtsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.passiveport1
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.PassiveMGMTIP.id
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "passiveport2" {
  name                          = "${var.passivename}-port2"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.publicsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.passiveport2
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "passiveport3" {
  name                          = "${var.passivename}-port3"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.private1subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.passiveport3
  }

  tags = local.common_tags
}

# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "passiveport1nsg" {
  depends_on                = [azurerm_network_interface.passiveport1]
  network_interface_id      = azurerm_network_interface.passiveport1.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "passiveport2nsg" {
  depends_on                = [azurerm_network_interface.passiveport2]
  network_interface_id      = azurerm_network_interface.passiveport2.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "passiveport3nsg" {
  depends_on                = [azurerm_network_interface.passiveport3]
  network_interface_id      = azurerm_network_interface.passiveport3.id
  network_security_group_id = azurerm_network_security_group.privatenetworknsg.id
}


resource "azurerm_role_definition" "sdn_connector_ha_role" {
  name        = "fgt-sdn-connector-ha-role"
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Custom role for FortiGate SDN Connector HA Failover"

  permissions {
    actions     = ["*/read",
                    "Microsoft.Network/routeTables/write",
                    "Microsoft.Network/routeTables/routes/write",
                    "Microsoft.Network/routeTables/routes/delete",
                    "Microsoft.Network/publicIPAddresses/write",
                    "Microsoft.Network/publicIPAddresses/join/action",
                    "Microsoft.Network/networkInterfaces/write",
                    "Microsoft.Network/networkSecurityGroups/write",
                    "Microsoft.Network/networkSecurityGroups/join/action",
                    "Microsoft.Network/virtualNetworks/subnets/join/action"]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}", 
  ]
}
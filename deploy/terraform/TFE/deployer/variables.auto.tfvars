/*-----------------------------------------------------------------------------8
|                                                                              |
|                                    TFVARS                                    |
|                                                                              |
+--------------------------------------4--------------------------------------*/
environment                                 = "Set in TFE Workspace"
location                                    = "Set in TFE Workspace"
management_network_name                     = "Set in TFE Workspace"
management_network_address_space            = "Set in TFE Workspace"
management_subnet_address_prefix            = "Set in TFE Workspace"
management_firewall_subnet_address_prefix   = "Set in TFE Workspace"
enable_deployer_public_ip                   = "Set in TFE Workspace"
firewall_deployment                         = "Set in TFE Workspace"

tags  = {
  Workload                                  = "SAP"
  Deployment                                = "SAP Deployment Automation Framework"
}

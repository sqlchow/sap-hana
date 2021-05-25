#
# Generic information
#
deployer_environment="MGMT"
#deployer_codename=""

deployer_location="westeurope"

#deployer_resourcegroup_name
#deployer_resourcegroup_arm_id

#
# Networking information
#

#deployer_vnet_mgmt_name=""
#deployer_vnet_mgmt_arm_id=""
deployer_vnet_address_space="10.10.20.0/25"

#deployer_sub_mgmt_name=""
#deployer_sub_mgmt_arm_id=""
deployer_sub_mgmt_prefix="10.10.20.64/28"

#deployer_sub_mgmt_nsg_arm_id=""
#deployer_sub_mgmt_nsg_allowed_ips=""

#deployer_sub_fw_arm_id= ""
deployer_sub_fw_prefix="10.10.20.0/26"

########################################################
#
#         Deployer VM information
#
########################################################
#deployer_size="Standard_D4ds_v4"
#deployer_disk_type"="Premium_LRS"
#deployer_use_DHCP=false
#deployer_private_ip_address=""

#
# This block describes the variables for the deployer OS section 
#

#deployer_os={
#    "source_image_id"=""
#    "publisher"      ="Canonical"
#    "offer"          ="UbuntuServer"
#    "sku"            ="18.04-LTS"
#    "version"        ="latest"
#}


/*
This block describes the variables for the authentication section block in the json file
*/

#deployer_authentication_type="key"
#deployer_authentication_username="azureadm"
#deployer_authentication_password=""
#deployer_authentication_path_to_public_key=""
#deployer_authentication_path_to_private_key=""

/*
This block describes the variables for the key_vault section block in the json file
*/


#deployer_key_vault_kv_user_id=""
#deployer_key_vault_kv_prvt_id=""
#deployer_key_vault_kv_sshkey_prvt=""
#deployer_key_vault_kv_sshkey_pub=""
#deployer_key_vault_kv_username=""
#deployer_key_vault_kv_pwd=""


/*
This block describes the variables for the options section block in the json file
*/

#deployer_options_enable_deployer_public_ip=false

deployer_firewall_deployment=true
#deployer_firewall_rule_subnets=[]
#deployer_firewall_allowed_ipaddresses=[]

#deployer_assign_subscription_permissions=true

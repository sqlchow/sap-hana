/*

This block describes the variable for the infrastructure block 

*/

variable "library_environment" {
  type        = string
  description = "This is the environment name of the deployer"
  default     = ""
}

variable "library_location" {
  type    = string
  default = ""
}

variable "library_resourcegroup_name" {
  default = ""
}

variable "library_resourcegroup_arm_id" {
  default = ""
}

/*

/*

This block describes the variable for the deployer block 

*/

variable "deployer_environment" {
  type        = string
  description = "This is the environment name of the deployer"
  default     = ""
}

variable "deployer_location" {
  type    = string
  default = ""
}

variable "deployer_vnet" {
  type    = string
  default = ""
}

variable "deployer_use" {
  default = true
}

/*
This block describes the variables for the key_vault section
*/

variable "library_key_vault_kv_user_id" {
  default = ""
}

variable "library_key_vault_kv_prvt_id" {
  default = ""
}

variable "library_key_vault_kv_spn_id" {
  default = ""
}

/*
This block describes the variables for the "SAPBits" storage account
*/


variable "library_sapbits_arm_id" {
  default = ""
}

variable "library_sapbits_account_tier" {
  default = "Standard"
}

variable "library_sapbits_account_replication_type" {
  default = "LRS"
}

variable "library_sapbits_account_kind" {
  default = "StorageV2"
}

variable "library_sapbits_file_share_enable_deployment" {
  default = true
}

variable "library_sapbits_file_share_is_existing" {
  default = false
}

variable "library_sapbits_file_share_name" {
  default = "sapbits"
}
variable "library_sapbits_blob_container_enable_deployment" {
  default = true
}

variable "library_sapbits_blob_container_is_existing" {
  default = false
}

variable "library_sapbits_blob_container_name" {
  default = "sapbits"
}


/*
This block describes the variables for the "TFState" storage account
*/


variable "library_tfstate_arm_id" {
  default = ""
}

variable "library_tfstate_account_tier" {
  default = "Standard"
}

variable "library_tfstate_account_replication_type" {
  default = "LRS"
}

variable "library_tfstate_account_kind" {
  default = "StorageV2"
}

variable "library_tfstate_blob_container_is_existing" {
  default = false
}

variable "library_tfstate_blob_container_name" {
  default = "tfstate"
}

variable "library_ansible_blob_container_is_existing" {
  default = false
}

variable "library_ansible_blob_container_name" {
  default = "ansible"
}

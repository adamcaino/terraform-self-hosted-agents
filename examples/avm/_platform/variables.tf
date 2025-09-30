# -- Workload specific variables --
variable "subscription_id" {
  description = "The Subscription ID which should be used to deploy resources in to."
  type        = string
}

variable "org" {
  description = "Configuration details for the organisation, to be used for naming and tags for all resources created."
  type = object({
    name   = string
    prefix = string
  })
  default = {
    name   = "Quadrivium Cloud"
    prefix = "qc"
  }
}

variable "workload_name" {
  description = "The name of the workload being deployed."
  type        = string
  default     = "CICD Platform"
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure region to deploy resources into."
  type = object({
    name      = string
    shortcode = string
  })
  default = {
    name      = "UK South"
    shortcode = "uks"
  }
}

# -- Network Security Group variables --
variable "user_ip_address" {
  description = "Your public IP address in CIDR notation."
  type        = string
}

# -- Virtual Network variables --
variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
  default     = ["192.168.0.0/16"]
}

variable "compute_subnet_address_prefixes" {
  description = "The address prefix for the compute subnet."
  type        = list(string)
  default     = ["192.168.0.0/24"]
}

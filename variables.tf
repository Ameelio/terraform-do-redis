# Input variable definitions
variable "app" {
  description = "Name of the application (ex. learn)"
  type        = string
}

variable "cluster_name" {
  description = "Optional override the generated cluster name"
  type        = string
  default     = null
  nullable    = true
}

variable "cpus" {
  description = "Number of CPUs per database node."
  type        = number
  default     = 2
}

variable "instance" {
  description = "Name of the instance (ex. staging, techgoeshome)"
  type        = string
}

variable "k8s" {
  description = "Name of the application (k8s) cluster."
  type        = string
}

variable "namespace" {
  description = "The k8s namespace for resources"
  type        = string
}

variable "memory_gb" {
  description = "The amount of memory allocated to the database."
  type        = number
  default     =  4
  validation {
    condition = var.memory_gb > 0 && (var.memory_gb == 1 || pow(2, floor(log(var.memory_gb, 2))) == var.memory_gb)
    error_message = "must be a power of two."
  }
}

variable "node_count" {
  description = "The number of database instances."
  type = number
  default = 1
}

variable "redis_version" {
  description = "Version of Redis to use.  Ex: 7"
  type        = string
  default     = "7"
}

variable "tier" {
  description = "Tier size of the postgres node. Ex: 's'"
  type        = string
  default     = "s"
}

variable "vpc" {
  description = "Digital Ocean Virtual Private Cloud this database will run within."
  type        = string
}

variable "vpn" {
  description = "Name of the VPN that users can connect with."
  type        = string
}

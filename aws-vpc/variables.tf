variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region to build in, eg: us-east-1"
}

variable "env_name" {
  type        = string
  description = "The proper name of the environment, eg: Production"
}

variable "subnet_prefix" {
  type        = string
  description = "The first two octets of the subnet, eg: 10.100"
}

variable "subnet_size" {
  type        = string
  default     = "/24"
  description = "The subnet mask bits that determine the size of the subnets."
}

variable "num_services_subnets" {
  type        = number
  default     = 2
  description = "The number of subnets to create for servers."
}

variable "num_database_subnets" {
  type        = number
  default     = 2
  description = "The number of subnets to create for databases."
}

variable "enable_public_dbs" {
  type        = bool
  default     = false
  description = "Whether to create public subnets for databases."
}

variable "cost_center" {
  type        = string
  default     = "Default"
  description = "The top level cost tracking tag, eg: Application"
}


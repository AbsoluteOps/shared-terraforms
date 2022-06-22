variable "organization_name" {
  description = "The name of the organization that will using the terraforms (alphanumeric and dashes only)."
  type        = string
}

variable "environment" {
  description = "The environment that the terraforms will be used in."
  type        = string
}

variable "region" {
  description = "The AWS region to create the resources in."
  default     = "us-east-1"
  type        = string
}
  

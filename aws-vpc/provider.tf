provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "Cost Center" = var.cost_center
      "AppCost"     = var.env_name
    }
  }
}

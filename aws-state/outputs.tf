output "example_backend" {
  value = <<EOT
# An example of the backend.tf file for terraforms that use this backend
terraform {
  backend "s3" {
    bucket  = "${aws_s3_bucket.tf-states.id}"
    key     = "${var.environment}/terraform.tfstate"
    region  = "${var.region}"
    encrypt = true

    dynamodb_table = "${aws_dynamodb_table.tf-states.id}"
  }
}
EOT
}

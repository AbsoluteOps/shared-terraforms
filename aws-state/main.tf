# Remote state storage
resource "aws_s3_bucket" "tf-states" {
    bucket = "${lower(var.organization_name)}-terraform-remote-states"
 
    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "tf-states" {
  bucket = aws_s3_bucket.tf-states.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Remote state locking
resource "aws_dynamodb_table" "tf-states" {
  name = "terraform-state-locks"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  billing_mode = "PAY_PER_REQUEST"
}

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
    

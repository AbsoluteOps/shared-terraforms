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


resource "aws_dynamodb_table" "authentication" {
  name                        = var.dynamo_table_name
  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = true
  hash_key                    = "UserId"
  read_capacity               = 20
  write_capacity              = 20

  attribute {
    name = "UserId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = var.dynamo_table_name
  }
}

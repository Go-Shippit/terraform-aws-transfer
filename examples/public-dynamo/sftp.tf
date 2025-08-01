provider "aws" {
  region = "eu-west-2"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "sftp" {
  // role for SFTP server
  name = "sftp-server-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role" "sftp_log" {
  // log role for SFTP server
  name = "sftp-server-iam-log-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "sftp" {
  // policy to allow invocation of IdP API
  name = "sftp-server-iam-policy"
  role = aws_iam_role.sftp.id

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "InvokeApi",
			"Effect": "Allow",
			"Action": [
				"execute-api:Invoke"
			],
			"Resource": "arn:aws:execute-api:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${module.idp.rest_api_id}/prod/GET/*"
		},
		{
			"Sid": "ReadApi",
			"Effect": "Allow",
			"Action": [
				"apigateway:GET"
			],
			"Resource": "*"
		}
	]
}
POLICY
}

resource "aws_iam_role_policy" "sftp_log" {
  // policy to allow logging to Cloudwatch
  name = "sftp-server-iam-log-policy"
  role = aws_iam_role.sftp_log.id

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [{
			"Sid": "AllowFullAccesstoCloudWatchLogs",
			"Effect": "Allow",
			"Action": [
				"logs:*"
			],
			"Resource": "*"
		}
	]
}
POLICY
}

resource "aws_transfer_server" "sftp" {
  identity_provider_type = "API_GATEWAY"
  logging_role           = aws_iam_role.sftp_log.arn
  // url from output of the module
  url             = module.idp.invoke_url
  invocation_role = aws_iam_role.sftp.arn
  endpoint_type   = "PUBLIC"

  tags = {
    NAME = "sftp-server"
  }
}


module "idp" {
  source            = "../.."
  dynamo_table_name = "my-sftp-authentication-table"
}

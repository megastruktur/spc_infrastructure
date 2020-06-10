# Lambda iAM role.
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Lambda function.
resource "aws_lambda_function" "name_generator" {

  s3_bucket = var.s3_bucket
  s3_key    = "name_generator/${var.app_version_name_generator}.zip"

  function_name = var.function_name_name_generator
  handler       = "main.handler"
  runtime       = "nodejs12.x"
  role          = aws_iam_role.iam_for_lambda.arn

}

# Attach API Gateway
module "api_gateway_name_generator" {
  source = "./modules/apiGateway"

  lambda_function_name = "NameGenerator"
  lambda_uri = aws_lambda_function.name_generator.invoke_arn
}

output "name_generator_base_url_dev" {
  value = module.api_gateway_name_generator.api_gateway_base_url_dev
}

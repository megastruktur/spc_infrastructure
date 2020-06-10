variable "aws_region" {
  description = "AWS region"
  type = string
}

variable "aws_hosted_zone" {
  description = "AWS Hosting Zone"
  type = string
}

variable "function_name_name_generator" {
  description = "Name Generator Function name"
  type = string
}

variable "app_version_name_generator" {
  description = "App version of the Name Generator Lambda"
  type = string
}

variable "s3_bucket" {
  description = "S3 Bucket name"
  type = string
}

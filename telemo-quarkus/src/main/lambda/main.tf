terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
  backend "s3" {}
}

variable "env_name" {
  type    = string
  default = "tf/env"

  validation {
    condition     = can(regex("[A-Za-z0-9-]*", var.env_name))
    error_message = "Environment name must not have weird chars."
  }
}

variable "vpc_id" {}
variable "subnet_a" {}
variable "subnet_b" {}
variable "subnet_c" {}
variable "ssl_arn" {}
variable "lambda_secg" {}
variable "lambda_role" {}
variable "bucket_name" {}
variable "QUARKUS_DATASOURCE_JDBC_URL" {}
variable "QUARKUS_DATASOURCE_DB_KIND" {}
variable "QUARKUS_DATASOURCE_USERNAME" {}
variable "QUARKUS_DATASOURCE_PASSWORD" {}
variable "QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION" {}

resource "aws_lambda_function" "telemo_lambda" {
  filename      = "../../../target/function.zip"
  function_name = "telemo_quarkus_${var.env_name}"
  role          = var.lambda_role
  handler       = "io.quarkus.amazon.lambda.runtime.QuarkusStreamHandler::handleRequest"
  memory_size = 1024
  runtime = "java11"
  timeout = 300

  vpc_config {
    subnet_ids         = [var.subnet_a, var.subnet_b, var.subnet_c]
    security_group_ids = [var.lambda_secg]
  }

  environment {
    variables = {
      QUARKUS_DATASOURCE_JDBC_URL=var.QUARKUS_DATASOURCE_JDBC_URL
      QUARKUS_DATASOURCE_USERNAME=var.QUARKUS_DATASOURCE_USERNAME
      QUARKUS_DATASOURCE_PASSWORD=var.QUARKUS_DATASOURCE_PASSWORD
      QUARKUS_DATASOURCE_DB_KIND=var.QUARKUS_DATASOURCE_DB_KIND
      QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION=var.QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION
    }
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = "api-${var.env_name}"
  protocol_type = "HTTP"
  target        = aws_lambda_function.telemo_lambda.arn
}

resource "aws_lambda_permission" "apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.telemo_lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

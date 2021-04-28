terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
}

variable "env_name" {
  type    = string
  default = "tfenv"

  validation {
    condition     = can(regex("[A-Za-z0-9]*", var.env_name))
    error_message = "Environment name must not have weird chars."
  }
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "vpc_id" {}
variable "subnets" {}
variable "ssl_arn" {}
variable "QUARKUS_DATASOURCE_JDBC_URL" {}
variable "QUARKUS_DATASOURCE_DB_KIND" {}
variable "QUARKUS_DATASOURCE_USERNAME" {}
variable "QUARKUS_DATASOURCE_PASSWORD" {}
variable "QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION" {}

locals {
  timestamp = timestamp()
  timelabel = replace(local.timestamp, "/[- TZ:]/", "")
  env_alias = replace(var.env_name, "/[/]/", "")
}

resource "aws_elastic_beanstalk_application" "telemo_app" {
  name = "telemo-eb-app-${local.env_alias}"
}

resource "aws_s3_bucket" "telemo_bucket" {
  bucket = "telemo-bucket-${local.env_alias}"
}

resource "aws_s3_bucket_object" "telemo_object" {
  key     = "telemo-eb-${local.timelabel}.zip"
  bucket  = aws_s3_bucket.telemo_bucket.bucket
  source  = "../../../target/telemo-eb.zip"
}

resource "aws_elastic_beanstalk_application_version" "telemo_version" {
  name        = "telemo-version-${local.env_alias}-${local.timelabel}"
  application = aws_elastic_beanstalk_application.telemo_app.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.telemo_bucket.id
  key         = aws_s3_bucket_object.telemo_object.id
}

resource "aws_elastic_beanstalk_environment" "telemo_env" {
  name                = "telemo-eb-env-${local.env_alias}"
  application         = aws_elastic_beanstalk_application.telemo_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.1.7 running Corretto 11"
  version_label       = aws_elastic_beanstalk_application_version.telemo_version.id

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "Application"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "8080"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = var.subnets
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORT"
    value     = "8080"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "QUARKUS_DATASOURCE_JDBC_URL"
    value     = var.QUARKUS_DATASOURCE_JDBC_URL
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "QUARKUS_DATASOURCE_DB_KIND"
    value     = var.QUARKUS_DATASOURCE_DB_KIND
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "QUARKUS_DATASOURCE_USERNAME"
    value     = var.QUARKUS_DATASOURCE_USERNAME
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "QUARKUS_DATASOURCE_PASSWORD"
    value     = var.QUARKUS_DATASOURCE_PASSWORD
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION"
    value     = var.QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "DefaultProcess"
    value     = "https"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = var.ssl_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:https"
    name      = "Port"
    value     = "8080"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:https"
    name      = "Protocol"
    value     = "HTTP"
  }
}


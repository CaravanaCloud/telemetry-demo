output "cname" {
  value = aws_elastic_beanstalk_environment.telemo_env.cname
}

output "enpoint_url" {
  value = aws_elastic_beanstalk_environment.telemo_env.endpoint_url
}

output "local_env_alias" {
  value = local.env_alias
}


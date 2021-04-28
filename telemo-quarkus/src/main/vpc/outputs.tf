output "vpc_id" {
  value = aws_vpc.telemo_vpc.id
}

output "subnet_a" {
  value = aws_subnet.telemo_net_pub_a.id
}

output "subnet_b" {
  value = aws_subnet.telemo_net_pub_b.id
}

output "subnet_c" {
  value = aws_subnet.telemo_net_pub_c.id
}


output "subnets" {
  value = "${aws_subnet.telemo_net_pub_a.id}, ${aws_subnet.telemo_net_pub_b.id}, ${aws_subnet.telemo_net_pub_c.id}"
}
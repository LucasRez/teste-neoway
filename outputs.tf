output "app_dns_name" {
  value = aws_alb.yawoen_alb.dns_name
}

output "bastion_host_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

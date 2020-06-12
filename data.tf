data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "latest_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = [
      "amzn2-ami-ecs-*"]
  }

  filter {
    name   = "virtualization-type"
    values = [
      "hvm"]
  }

  owners = [
    "amazon"
  ]
}

data "aws_ami" "latest_ec2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = [
    "amazon"
  ]
}

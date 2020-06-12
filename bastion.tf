resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_ec2.id
  key_name                    = aws_key_pair.yawoen_key_pair.key_name
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.bastion_instance_sg.id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true
}
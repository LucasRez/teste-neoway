resource "aws_launch_configuration" "ecs_launch_configuration" {
  name_prefix                 = "ecs-launch-configuration-"
  image_id                    = data.aws_ami.latest_ecs.id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.id
  security_groups             = [aws_security_group.ec2_instances_sg.id]
  key_name                    = aws_key_pair.yawoen_key_pair.key_name
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOT
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.yawoen_ecs_cluster.name} >> /etc/ecs/ecs.config
  EOT
}

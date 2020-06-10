provider "aws" {
  region = "us-east-1"
}

# Define a vpc
resource "aws_vpc" "yawoenVPC" { 
	cidr_block = "200.0.0.0/16"
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "yawoenIG" { 
  vpc_id = aws_vpc.yawoenVPC.id
}

# Public subnet
resource "aws_subnet" "yawoenPubSN0-0" { 
  vpc_id = aws_vpc.yawoenVPC.id
  cidr_block = "200.0.0.0/24"
  availability_zone = "us-east-1a"
}

# Routing table for public subnet
resource "aws_route_table" "yawoenPubSN0-0RT" { 
  vpc_id = aws_vpc.yawoenVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.yawoenIG.id
  }
}

# Associate the routing table to the public subnet
resource "aws_route_table_association" "yawoenPubSN0-0RTAssn" { 
  subnet_id = aws_subnet.yawoenPubSN0-0.id
  route_table_id = aws_route_table.yawoenPubSN0-0RT.id
}

# Public subnet 2
resource "aws_subnet" "yawoenPubSN0-1" { 
  vpc_id = aws_vpc.yawoenVPC.id
  cidr_block = "200.0.1.0/24"
  availability_zone = "us-east-1b"
}

# Routing table for public subnet
resource "aws_route_table" "yawoenPubSN0-1RT" { 
  vpc_id = aws_vpc.yawoenVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.yawoenIG.id
  }
}

# Associate the routing table to the public subnet
resource "aws_route_table_association" "yawoenPubSN0-1RTAssn" { 
  subnet_id = aws_subnet.yawoenPubSN0-1.id
  route_table_id = aws_route_table.yawoenPubSN0-1RT.id
}

# ECS Instance Security group

resource "aws_security_group" "yawoen_public_sg" {
    name = "yawoen_public_sg"
    description = "Yawoen public access security group"
    vpc_id = aws_vpc.yawoenVPC.id

   ingress {
       from_port = 22
       to_port = 22
       protocol = "tcp"
       cidr_blocks = [
          "0.0.0.0/0"]
   }

   ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
   }

   ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
    }

    egress {
        # allow all traffic to private SN
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = [
            "0.0.0.0/0"]
    }
}

# ECS Service role
resource "aws_iam_role" "ecs-service-role" {
    name                = "ecs-service-role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.ecs-service-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
    role       = aws_iam_role.ecs-service-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

# ECS Instance role
resource "aws_iam_role" "ecs-instance-role" {
    name                = "ecs-instance-role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.ecs-instance-policy.json
}

data "aws_iam_policy_document" "ecs-instance-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role       = aws_iam_role.ecs-instance-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile"
    path = "/"
    role = aws_iam_role.ecs-instance-role.id
}

# Application Load Balancer
resource "aws_alb" "ecs-load-balancer" {
    name                = "ecs-load-balancer"
    security_groups     = [aws_security_group.yawoen_public_sg.id]
    subnets             = [aws_subnet.yawoenPubSN0-0.id, aws_subnet.yawoenPubSN0-1.id]
}

resource "aws_alb_target_group" "ecs-target-group" {
    name                = "ecs-target-group"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = aws_vpc.yawoenVPC.id

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }
}

resource "aws_alb_listener" "alb-listener" {
    load_balancer_arn = aws_alb.ecs-load-balancer.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = aws_alb_target_group.ecs-target-group.arn
        type             = "forward"
    }
}

# Launch Configuration
resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "ecs-launch-configuration"
    image_id                    = "ami-05801d0a3c8e4c443"
    instance_type               = "t2.micro"
    iam_instance_profile        = aws_iam_instance_profile.ecs-instance-profile.id

    root_block_device {
      volume_type = "standard"
      volume_size = 100
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = [aws_security_group.yawoen_public_sg.id]
    associate_public_ip_address = "true"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER="yawoen_ecs_cluster" >> /etc/ecs/ecs.config
                                  EOF
}

# Autoscaling group
resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                        = "ecs-autoscaling-group"
  max_size                    = 2
  min_size                    = 1
  desired_capacity            = 2
  vpc_zone_identifier         = [aws_subnet.yawoenPubSN0-0.id, aws_subnet.yawoenPubSN0-1.id]
  launch_configuration        = aws_launch_configuration.ecs-launch-configuration.name
  health_check_type           = "ELB"
}

# ECS Cluster
resource "aws_ecs_cluster" "test-ecs-cluster" {
  name = "yawoen_ecs_cluster"
}

# Task definition

resource "aws_ecs_task_definition" "whoami" {
  family                = "whoami"
  container_definitions = <<DEFINITION
  [
    {
      "name": "whoami",
      "image": "jwilder/whoami",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8000,
          "hostPort": 80
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
}
resource "aws_alb_target_group" "yawoen" {
  name     = "yawoen-alb-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_alb" "yawoen_alb" {
  name            = "yawoen-alb-ecs"
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.ec2_instances_sg.id]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.yawoen_alb.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.yawoen.id
    type             = "forward"
  }
}
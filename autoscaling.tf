resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name = "ecs-autoscaling-group"
  max_size = 2
  min_size = 2
  desired_capacity = 2

  vpc_zone_identifier = module.vpc.public_subnets
  launch_configuration = aws_launch_configuration.ecs_launch_configuration.name
  health_check_type = "ELB"
  target_group_arns = [aws_alb_target_group.yawoen.id]

  tag {
    key = "Name"
    value = "ECS-yawoen-ecs-cluster"
    propagate_at_launch = true
  }
}

# Start all instances at 7:00 (10:00 UTC)
resource "aws_autoscaling_schedule" "yawoen_start_instances" {
  scheduled_action_name  = "yawoen-start-instances"
  min_size               = 2
  max_size               = 2
  desired_capacity       = 2
  recurrence = "0 10 * * *"
  autoscaling_group_name = aws_autoscaling_group.ecs_autoscaling_group.name
}

# Stop all instances at 19:00 (22:00 UTC)
resource "aws_autoscaling_schedule" "yawoen_stop_instances" {
  scheduled_action_name  = "yawoen-stop-instances"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence = "0 22 * * *"
  autoscaling_group_name = aws_autoscaling_group.ecs_autoscaling_group.name
}
resource "aws_ecs_service" "yawoen_ecs_service" {
  name                = "yawoen-ecs-service"
  cluster             = aws_ecs_cluster.yawoen_ecs_cluster.id
  task_definition     = aws_ecs_task_definition.yawoen_whoami.family
  iam_role            = aws_iam_role.ecs_service_role.arn
  scheduling_strategy = "DAEMON"
  depends_on          = [aws_alb_listener.front_end]

  load_balancer {
    target_group_arn = aws_alb_target_group.yawoen.id
    container_name   = "yawoen-whoami"
    container_port   = 8000
  }

}
data "aws_ecs_task_definition" "test" {
  task_definition = aws_ecs_task_definition.yawoen_whoami.family
  depends_on      = [aws_ecs_task_definition.yawoen_whoami]
}

resource "aws_ecs_task_definition" "yawoen_whoami" {
  family                = "yawoen-whoami"
  container_definitions = <<DEFINITION
  [
    {
      "name": "yawoen-whoami",
      "image": "jwilder/whoami",
      "memory": 256,
      "cpu": 256,
      "essential": true,
      "networkMode": "host",
      "portMappings": [
        {
          "hostPort": 80,
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ]
    }
  ]
  DEFINITION
}
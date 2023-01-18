resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.env}-ecsTaskExecutionRole-betaflux-test"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.env}-ecsTaskRole-betaflux-test"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "betaflux-test" {
  name = "/ecs/${var.env}-task-betaflux-test"

  tags = {
    Name = "${var.env}-task-betaflux-test"
  }
}

resource "aws_ecs_task_definition" "betaflux-test" {
  family                   = "${var.env}-task-betaflux-test"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name      = "${var.env}-betaflux-test"
    image     = var.container_image
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.betaflux-test.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
  }])

  tags = {
    Name = "${var.env}-task-betaflux-test"
  }
}

resource "aws_ecs_cluster" "betaflux-test" {
  name = "${var.env}-cluster-betaflux-test"
  tags = {
    Name = "${var.env}-cluster-betaflux-test"
  }
}

resource "aws_ecs_service" "betaflux-test" {
  name                               = "${var.env}-betaflux-test"
  cluster                            = aws_ecs_cluster.betaflux-test.id
  task_definition                    = aws_ecs_task_definition.betaflux-test.arn
  desired_count                      = var.service_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.betaflux-test.id]
    subnets          = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id, aws_subnet.private-subnet-3.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.betaflux-test-tg.arn
    container_name   = "${var.env}-betaflux-test"
    container_port   = var.container_port
  }
}

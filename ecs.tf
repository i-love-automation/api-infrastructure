resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-api"

  tags = local.tags
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

#data "aws_vpc" "taxi_aymeric_vpc" {
#  tags = {
#    Name = "taxi-aymeric-vpc"
#  }
#}

# TODO passer sur les subnets privés
#data "aws_subnet" "public_subnets" {
#  count  = 2
#  vpc_id = data.aws_vpc.taxi_aymeric_vpc.id
#  tags = {
#    Name = "public_${count.index + 1}"
#  }
#}
#
#data "aws_lb_target_group" "load_balancer_target_group" {
#  name = "load-balancer-api-target-group"
#}
#
#data "aws_db_instance" "taxi_rds_instance" {
#  db_instance_identifier = "taxi"
#}
#
#data "aws_db_instance" "taxi_rds_instance_2" {
#  db_instance_identifier = "taxi-2"
#}
#
#locals {
#  connexionString  = "postgres://${var.db_username}:${var.db_password}@${data.aws_db_instance.taxi_rds_instance.endpoint}/${data.aws_db_instance.taxi_rds_instance.db_name}"
#  connexionString2 = "postgres://${var.db_username}:${var.db_password}@${data.aws_db_instance.taxi_rds_instance_2.endpoint}/${data.aws_db_instance.taxi_rds_instance_2.db_name}"
#}



variable "container" {
  default = ""
}

variable "container_tag" {
  default = ""
}
resource "aws_ecs_task_definition" "task_definition" {
  family             = "node-server"
  execution_role_arn = var.task_definition_execution_role_arn //aws_iam_role.task_definition_execution_role.arn
  container_definitions = jsonencode([
    {
      name : var.project,
      image : "${aws_ecr_repository.api.repository_url}:${var.container_tag}", //"860265624594.dkr.ecr.us-east-1.amazonaws.com/${var.container}:${var.container_tag}",
      environment : [
        { "name" : "PORT", "value" : "80" },
        { "name" : "DATABASE_URL", "value" : var.db_connexion_string }
      ],
      portMappings : [
        {
          "name" : "http",
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      essential : true,
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          awslogs-create-group : "true",
          awslogs-group : "/ecs/${var.project}",
          awslogs-region : "us-east-1",
          awslogs-stream-prefix : "ecs"
        }
      }
    }
  ])

  cpu          = 1024
  memory       = 2048
  network_mode = "awsvpc"

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  requires_compatibilities = ["FARGATE"]
}

resource "null_resource" "always_run" {
  triggers = {
    timestamp = timestamp()
  }
}


resource "aws_ecs_service" "api_service" {
  name                              = var.project
  cluster                           = aws_ecs_cluster.cluster.id
  task_definition                   = aws_ecs_task_definition.task_definition.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.load_balancer_target_group_api.arn
    container_name   = var.project
    container_port   = 80
  }

  # Public IP is the easiest way to be able to pull on ECR: https://stackoverflow.com/questions/61265108/aws-ecs-fargate-resourceinitializationerror-unable-to-pull-secrets-or-registry
  network_configuration {
    security_groups  = [aws_security_group.security_group_api_service.id]
    subnets          = var.public_subnets_id // data.aws_subnet.public_subnets.*.id
    assign_public_ip = true
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}
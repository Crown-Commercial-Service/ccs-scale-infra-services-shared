
#########################################################
# Service: Agreements ECS
#
# ECS Fargate Service and Task Definitions.
#########################################################
module "globals" {
  source = "../../globals"
}

#######################################################################
# NLB target group & listener for traffic on port 9010 (Agreements API)
#######################################################################
resource "aws_lb_target_group" "target_group_9010" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-TG-Agreements"
  port        = 9010
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "LOADBALANCER"
  }
}

resource "aws_lb_listener" "port_9010" {
  load_balancer_arn = var.lb_private_arn
  port              = "9010"
  protocol          = "TCP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_9010.arn
  }
}

resource "aws_ecs_service" "agreements" {
  name             = "SCALE-EU2-${upper(var.environment)}-APP-ECS_Service_Agreements"
  cluster          = var.ecs_cluster_id
  task_definition  = aws_ecs_task_definition.agreements.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = 1

  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.private_app_subnet_ids
    assign_public_ip = false # Replace NAT GW and disable this by replacement AWS PrivateLink
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_9010.arn
    container_name   = "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_Agreements"
    container_port   = 9010
  }
}

resource "aws_ecs_task_definition" "agreements" {
  family                   = "agreements"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.ecs_task_execution_arn

  container_definitions = <<DEFINITION
    [
      {
        "name": "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_Agreements",
        "image": "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/agreements-service:947c9b5-candidate",
        "requires_compatibilities": "FARGATE",
        "cpu": 256,
        "memory": 512,
        "essential": true,
        "networkMode": "awsvpc",
        "portMappings": [
            {
            "containerPort": 9010,
            "hostPort": 9010
            }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.fargate_scale.name}",
              "awslogs-region": "eu-west-2",
              "awslogs-stream-prefix": "fargate-agreements"
          }
        }
      }
    ]
DEFINITION

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "ECS"
  }
}

resource "aws_cloudwatch_log_group" "fargate_scale" {
  name_prefix       = "/fargate/service/scale/agreements"
  retention_in_days = 7
}

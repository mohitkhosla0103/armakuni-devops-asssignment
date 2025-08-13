resource "aws_lb_target_group" "this" {
   for_each = var.attach_load_balancer ? { for idx, port_mapping in var.port_mappings : port_mapping.containerPort => port_mapping } : {}


  name        = "${var.tg-name}-${each.key}"  # Unique name for each port
  port        = each.key
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.container_runtime == "EC2" ? "instance" : "ip"    # for fargate container runtime ip will be the target type

  health_check {
    path                = lookup(var.health_check_paths,each.key,"/")
    protocol            = "HTTP"
    port                = var.container_runtime == "EC2" ? "traffic-port" : each.value.hostPort
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge(
    {
      "Name" = "${var.tg-name}-${each.key}"
    },
    var.extra_tags
  )
}

resource "aws_lb_listener_rule" "backend_rule" {
   for_each = var.attach_load_balancer ? { for idx, port_mapping in var.port_mappings : port_mapping.containerPort => port_mapping } : {}


  listener_arn = var.listener_arn
  priority     = var.listener_rule_priority + each.key  # Ensure unique priority for each port

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

    condition {
    dynamic "path_pattern" {
      for_each = each.value.path_pattern != "" ? [each.value.path_pattern] : []
      content {
        values = [each.value.path_pattern]
      }
    }
    }
    
    condition{
    dynamic "host_header" {
      for_each = each.value.host_header != "" ? [each.value.host_header] : []
      content {
        values = [each.value.host_header]
      }
    }
  }
}


############################################################################
#                            Task Definition                               #                          
############################################################################


resource "aws_iam_policy" "ecs_secrets_access_policy" {
  name        = var.ecs_secrets_access_policy
  description = "Policy for ECS tasks to access Secrets Manager"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : "${var.ecs_secrets_access_policy_resource_arn}"
      }
    ]
  })
}
resource "aws_iam_role" "ecs_task_role" {
  name = var.ecs_task_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    aws_iam_policy.ecs_secrets_access_policy.arn
  ]

  tags = merge(
    {
      "Name"             = var.ecs_task_role
      "TerraformManaged" = true
    }
  )
}


resource "aws_ecs_task_definition" "task_definition" {

  family                   = var.ecs_task_family
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities

  cpu    = var.task_cpu
  memory = var.task_memory

  container_definitions = jsonencode([
    {
      "name" : "${var.ecs_container_name}",
      "image" : "${var.ecs_container_image}",
      "memoryReservation" : "${var.softLimit}", # number
      "cpu" : "${var.cpu}",
      "memory" : "${var.hardLimit}", # number
      "portMappings" : [
         for port_mapping in var.port_mappings : {
          "containerPort" : port_mapping.containerPort,
          "hostPort"      : port_mapping.hostPort,
          "protocol"      : port_mapping.protocol,
          "name"          : port_mapping.name
        }
      ]
      "environment" : "${var.env_task_defintions}",
      "secrets" : "${var.secrets}"
      "logConfiguration" : {
        "logDriver" : "awslogs"
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "${var.ecs_awslogs_group}",
          "awslogs-region" : "${var.ecs_region}",
          "awslogs-stream-prefix" : "${var.ecs_awslogs_stream}"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.cpu_architecture
  }

  tags = merge(
    {
      "Name"             = var.ecs_task_family
    },
    var.extra_tags
  )

  # depends_on = [aws_iam_role.ecs_task_role]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.ecs_awslogs_group
  retention_in_days = 7

  tags = merge(
    {
      "Name"             = var.ecs_awslogs_group
    },
    var.extra_tags
  )
}

############################################################################
#                              ECS Service                                 #                          
############################################################################
resource "aws_ecs_service" "ecs_service" {
  name                = var.ecs_service_name
  cluster             = var.ecs_service_cluster_id
  task_definition     = aws_ecs_task_definition.task_definition.arn
  desired_count       = var.desired_count # number
  scheduling_strategy = var.container_runtime == "EC2" ? var.scheduling_strategy : null

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = var.attach_load_balancer ? 180 : null
  launch_type                        = var.container_runtime == "EC2" ? "EC2" : "FARGATE"

   dynamic "load_balancer" {
       for_each = var.attach_load_balancer ? var.port_mappings : []
      content {
        target_group_arn = aws_lb_target_group.this[load_balancer.value.containerPort].arn
        container_name   = var.ecs_container_name
        container_port   = load_balancer.value.containerPort
      }
    }

    dynamic "ordered_placement_strategy"{
      for_each = var.container_runtime == "EC2" ? [1] : []
        content{
          field = "attribute:ecs.availability-zone"
          type  = "spread"
        }
    }

    dynamic "service_registries" {
        for_each = var.is_internal_service ? [1] : []
        content{
              registry_arn   = aws_service_discovery_service.service_discovery[0].arn
              container_name = var.ecs_container_name
            }
    }


    dynamic "network_configuration" {
      for_each = var.is_internal_service || var.container_runtime == "FARGATE" || var.container_runtime == "fargate" ? [1] : []
      content{
          subnets         = var.private_subnet_ids
          security_groups = var.security_group_ids
      }
    }

  tags = merge(
    {
      "Name"             = var.ecs_service_name
    },
    var.extra_tags
  )

  depends_on = [
    aws_ecs_task_definition.task_definition,
    aws_service_discovery_service.service_discovery
  ]
}


###############################################################################
#                              Autoscaling                                    #
###############################################################################


resource "aws_appautoscaling_target" "target" {
  count              = var.autoscaling_enabled ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_service_cluster_name}/${var.ecs_service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  # role_arn           = aws_iam_role.ecs_auto_scale_role.arn
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity

  tags = merge(
    {
      "Name"             = "service/${var.ecs_service_cluster_name}/${var.ecs_service_name}"
    },
    var.extra_tags
  )
   depends_on = [aws_ecs_service.ecs_service]
}

resource "aws_appautoscaling_policy" "up" {
  count              = (var.autoscaling_enabled) ? 1 : 0
  name               = "${var.ecs_service_name}-scale-up"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.target[0].resource_id
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  target_tracking_scaling_policy_configuration {
    target_value = 80 # Scale when CPU utilization exceeds 80%
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }

  depends_on = [aws_appautoscaling_target.target[0],aws_ecs_service.ecs_service]
}

resource "aws_service_discovery_service" "service_discovery" {
  count       = var.is_internal_service ? 1 : 0
  name = "${var.ecs_service_name}"

  dns_config {
    namespace_id = var.service_discovery_private_dns_id
    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
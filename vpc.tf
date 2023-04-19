resource "aws_security_group" "security_group_api_load_balancer" {
  name        = "security-group-api-load-balancer"
  description = "Allow http and https inbound traffic"
  vpc_id      = var.vpc_id //aws_vpc.taxi_aymeric_vpc.id

  tags = merge(local.tags, { "Name" = "security-group-api-load-balancer" })

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

resource "aws_security_group" "security_group_api_service" {
  name        = "security-group-api-service"
  description = "Allow all inbound / outbound to load balancer"
  vpc_id      = var.vpc_id //data.aws_vpc.taxi_aymeric_vpc.id

  tags = merge(local.tags, { "Name" = "security-group-api-service" })

  lifecycle {
    # Necessary if changing 'name' or 'name_prefix' properties.
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_http_from_api_gateway" {
  type              = "ingress"
  description       = "Allow incoming HTTP traffic from anyone"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.security_group_api_load_balancer.id
}

// TODO Restrict to ecs service
resource "aws_security_group_rule" "allow_outgoing_to_ecs_service" {
  description       = "Load balancer to target service"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group_api_load_balancer.id
}

resource "aws_security_group_rule" "allow_all_from_load_balancer" {
  type                     = "ingress"
  description              = "Allow all incoming traffic from load balancer"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_api_load_balancer.id
  security_group_id        = aws_security_group.security_group_api_service.id
}

resource "aws_security_group_rule" "allow_all_outgoing" {
  type                     = "egress"
  description              = "Allow all outgoing traffic to load balancer"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_api_load_balancer.id
  security_group_id        = aws_security_group.security_group_api_service.id
}

resource "aws_security_group_rule" "allow_https_for_ecr" {
  type              = "ingress"
  description       = "Allow incoming HTTPS traffic for ecr"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.security_group_api_service.id
}

resource "aws_security_group_rule" "allow_all_outgoing_for_ecr" {
  type              = "egress"
  description       = "Allow outgoing traffic for ecr"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.security_group_api_service.id
}


resource "aws_security_group_rule" "allow_outgoing_to_service" {
  type                     = "egress"
  description              = "Allow outgoing traffic from load balancer to api service"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.security_group_api_service.id
  security_group_id        = aws_security_group.security_group_api_load_balancer.id
}
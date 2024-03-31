resource "aws_security_group" "asg_security_group" {
  name        = var.asg_security_group_name
  description = "ASG Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.asg_security_group_name
  }
}

resource "aws_launch_template" "launch_template" {
  name          = var.launch_template_name
  image_id      = var.ami
  instance_type = var.instance_type

  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.asg_security_group.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      ProjectName = var.launch_template_name
      Name        = var.instance_name
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"  
    ebs {
      volume_size          = 20  
      volume_type          = "gp2"  
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"  # Additional volume device name
    ebs {
      volume_size          = 20  
      volume_type          = "gp2"  
      delete_on_termination = true
    }
  }
  #user data file contents
  user_data = filebase64("${path.module}/nginx.sh")
  
  # SSH Key Pair Configuration
  key_name = var.ssh_key_name
  iam_instance_profile {
    name = var.instance_profile_name
  }
}




# CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name          = "CPUUtilizationHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"  
  statistic           = "Average"
  threshold           = "50"   
  alarm_description   = "Alarm when CPU utilization exceeds 50%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.auto_scaling_group.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_out_policy.arn]
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "ScaleOutPolicy"
  scaling_adjustment     = 1  
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.name
}


resource "aws_autoscaling_group" "auto_scaling_group" {
  name = var.asg_name
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.target_group.arn]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
   enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupInServiceCapacity",
    "GroupPendingInstances",
    "GroupPendingCapacity",
    "GroupTerminatingInstances",
    "GroupTerminatingCapacity",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTotalInstances",
    "GroupTotalCapacity",
    "WarmPoolMinSize",
    "WarmPoolDesiredCapacity",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolWarmedCapacity",
    "WarmPoolTotalCapacity",
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity"
   ]
}

#Alb

resource "aws_security_group" "alb_security_group" {
  name        = var.alb_security_group_name
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.alb_security_group_name
  }
}

resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "target_group" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path    = "/"
    matcher = 200
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
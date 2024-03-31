variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "public_subnet_ids" {
  description = "List of IDs of the public subnets"
}
variable "ssh_key_name" {
  description = "ssh key name"
  default = "cs"
}

#autoscaling_group
variable "instance_name" {
  description = "instance server name"
  type = string
  default = "web-server"
  
}
variable "asg_name" {
  description = "asg name"
  type = string
  default = "Web-server-asg" 
}
variable "asg_security_group_name" {
  description = "Name for the ASG Security Group"
  type        = string
  default = "Webserver-asg-sg"
}
variable "launch_template_name" {
  description = "Name for the Launch Template"
  type        = string
  default = "Webserver-launch-template"
}
variable "instance_type" {
  description = "Instance type for the Launch Template"
  type        = string
  default     = "t2.micro"
}
variable "ami" {
  description = "ami id"
  type        = string
  default     = "ami-007020fd9c84e18c7"
}
variable "desired_capacity" {
  description = "Desired capacity for the Auto Scaling Group"
  type        = number
  default     = 1
}
variable "instance_profile_name" {
  description = "Instance profile name for Auto scaling Group"
}

variable "max_size" {
  description = "Maximum size for the Auto Scaling Group"
  type        = number
  default = 3
}

variable "min_size" {
  description = "Minimum size for the Auto Scaling Group"
  type        = number
  default = 1
}

#loadbalancer
variable "alb_name" {
  description = "Name for the Application Load Balancer"
  type        = string
  default = "Webserver-alb"
}
variable "target_group_name" {
  description = "Name for the Target Group"
  type        = string
  default = "Webserver-tg-alb"
}
variable "alb_security_group_name" {
  description = "Name for the ALB Security Group"
  type        = string
  default = "Webserver-alb-sg"
}
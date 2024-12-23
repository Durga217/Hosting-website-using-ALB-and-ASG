provider "aws" {
region = var.region
}
# Security Group for EC2 and Load Balancer
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP traffic"
  vpc_id      = "vpc-04f397dac4594c401"
  ingress {
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
}
# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-04f397dac4594c401"
}
# Load Balancer
resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.subnets
}
# Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
# Launch Template
resource "aws_launch_template" "web_template" {
  name          = "web-app-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data = filebase64("userdata.sh")
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}
# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
  min_size         = 1
  max_size         = 3
  desired_capacity = 2
  target_group_arns = [aws_lb_target_group.web_tg.arn]
  vpc_zone_identifier = var.subnets
}
# Route 53 Record
resource "aws_route53_record" "web_dns" {
  zone_id = "Z04066151DVX3ZXCC4IXP"
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.web_lb.dns_name
    zone_id                = aws_lb.web_lb.zone_id
    evaluate_target_health = true
  }
}

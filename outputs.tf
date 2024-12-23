output "load_balancer_dns" {
  description = "DNS name of the Load Balancer"
  value       = aws_lb.web_lb.dns_name
}

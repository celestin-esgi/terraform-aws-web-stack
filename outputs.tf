output "alb_dns_name" {
  description = "Nom DNS public de l'Application Load Balancer"
  value       = aws_lb.web.dns_name
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "web_security_group_id" {
  description = "A referencer pour autoriser les instances aupres d'un autre service"
  value       = aws_security_group.web.id
}

output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}

output "asg_name" {
  description = "Utile pour les scripts de stop et de start en fin de journee"
  value       = aws_autoscaling_group.web.name
}

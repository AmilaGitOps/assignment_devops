output "alb_security_group_id" { value = aws_security_group.alb.id }
output "service_url" { value = "http://${aws_lb.public.dns_name}" }
output "load_balancer_arn" { value = aws_lb.public.arn }
output "target_group_arn" { value = aws_lb_target_group.app.arn }
output "dns_name" { value = aws_lb.public.dns_name }

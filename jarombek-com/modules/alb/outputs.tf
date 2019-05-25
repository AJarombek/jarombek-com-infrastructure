/**
 * Ouput variables for the ALB needed for ECS
 * Author: Andrew Jarombek
 * Date: 4/23/2019
 */

output "depended_on" {
  description = "Resources that other modules depend on"
  value = null_resource.dependency-setter.id
}

output "alb-sg" {
  description = "Security Group for the ALB"
  value = aws_security_group.jarombek-com-lb-security-group.id
}

output "jarombek-com-lb-target-group" {
  description = "Target Group for the jarombek-com Load Balancer"
  value = aws_lb_target_group.jarombek-com-lb-target-group.arn
}
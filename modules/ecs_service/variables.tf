variable "environment_name" { type = string }
variable "service_name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "alb_security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "task_definition_arn" { type = string }
variable "container_port" {
  type    = number
  default = 80
}
variable "desired_count" {
  type    = number
  default = 1
}
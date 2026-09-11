variable "environment_name" { type = string }
variable "app_stack_name" { type = string }
variable "service_name" { type = string }
variable "image_tag" {
  type    = string
  default = "latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "cpu" {
  type    = number
  default = 512
}

variable "memory" {
  type    = number
  default = 1024
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "create_ecr_repository" {
  type    = bool
  default = true
}
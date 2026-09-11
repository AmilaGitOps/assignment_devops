variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "environment_name" {
  type    = string
  default = "dev"
}



variable "vpc_cidr" {
  type    = string
  default = "172.31.0.0/16"
}

variable "public_subnet_1_cidr" {
  type    = string
  default = "172.31.0.0/22"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "172.31.4.0/22"
}

variable "private_subnet_1_cidr" {
  type    = string
  default = "172.31.16.0/20"
}

variable "private_subnet_2_cidr" {
  type    = string
  default = "172.31.32.0/20"
}

variable "app_stack_name" {
  type    = string
  default = "property-service-api"
}

variable "service_name" {
  type    = string
  default = "property-service-api"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "db_user" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "IdentityDB"
}

variable "aurora_engine_version" {
  type    = string
  default = "8.0.mysql_aurora.3.08.2"
}

variable "serverless_min_acu" {
  type    = number
  default = 0.5
}

variable "serverless_max_acu" {
  type    = number
  default = 4
}
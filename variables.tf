variable "enabled" {
  default     = "true"
  description = "Enable module creation"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
}

variable "aws_security_group_id" {
}

variable "aws_subnet_ids" {
  type = "list"
}

variable "aws_alb_target_group_id" {
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "adongy/hostname-docker:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "prefix" {
  default     = "app-dev"
}

variable "container_env" {
  default     = "[]"
}

variable "health_grace_period" {
  default     = "120"
}

variable "logwatch_retention" {
  default     = 30
}

variable "execution_role" {
  default     = ""
  description = "Fixed name execution role for container task"
}

variable "project" {
  type        = string
  nullable    = false
  description = "The name of the project that hosts the environment"
}

variable "service" {
  type        = string
  nullable    = false
  description = "The name of the service that will be run on the environment"
}

variable "task_definition_execution_role_arn" {
  default = ""
}

variable "db_connexion_string" {
  default = ""
}

variable "project_vpc_id" {
  default = ""
}

variable "private_subnets_ids" {
  default = ""
}

variable "public_subnets_id" {
  default = ""
}
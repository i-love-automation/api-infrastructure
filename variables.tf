variable "terraform_organization" {
  type        = string
  description = "The organization name on terraform cloud"
  nullable    = false
}

variable "tfe_token" {
  description = "TFE Team token"
  nullable    = false
  default     = false
  sensitive   = true
}

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

variable "db_connexion_string" {
  type        = string
  nullable    = false
  description = "A connexion string to the database associated with this api"
}

variable "private_subnets_ids" {
  type        = list(string)
  nullable    = false
  description = "The ids of the project vpc private subnets where the api is hosted"
}

# TODO We put the service in the public subnet to be able to pull on ECR,
# but maybe it is a bad practice and we should put it on the private subnets and toggle the route association to access the igw temporarily
# Public IP is the easiest way to be able to pull on ECR: https://stackoverflow.com/questions/61265108/aws-ecs-fargate-resourceinitializationerror-unable-to-pull-secrets-or-registry
variable "public_subnets_ids" {
  type        = list(string)
  nullable    = false
  description = "The ids of the project vpc public subnets where the service is hosted, "
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "The id of the project vpc"
}

variable "cognito_authorizer_issuer" {
  type        = string
  nullable    = false
  description = "The cognito issuer that generated the token"
}
variable "cognito_authorizer_audience" {
  type        = list(string)
  nullable    = false
  description = "The cognito audience that is allowed to interact with the token"
}
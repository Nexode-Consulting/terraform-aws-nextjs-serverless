variable "runtime" {
  type    = string
  default = "nodejs16.x"
}

variable "lambda_memory_size" {
  type    = number
  default = 2048
}

variable "logs_retention" {
  type    = number
  default = 30
}

variable "deployment_name" {
  type = string
}

variable "region" {
  type = string
}

variable "base_dir" {
  type = string
}

variable "next_lambda_env_vars" {
  type = map(any)
}

variable "next_lambda_policy_statements" {
  type = map(any)
}

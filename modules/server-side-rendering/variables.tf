variable "runtime" {
  type = string
}

variable "lambda_memory_size" {
  type = number
}

variable "logs_retention" {
  type = number
}

variable "deployment_name" {
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

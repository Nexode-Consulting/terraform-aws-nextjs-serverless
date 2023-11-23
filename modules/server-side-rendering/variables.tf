variable "next_lambda_runtime" {
  type = string
}

variable "next_lambda_memory_size" {
  type = number
}

variable "next_lambda_logs_retention" {
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

variable "next_lambda_ephemeral_storage_size" {
  type = number
}

variable "api_gateway_log_format" {
  type = string
}

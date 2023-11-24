variable "image_optimization_runtime" {
  type = string
}

variable "image_optimization_logs_retention" {
  type = number
}

variable "deployment_name" {
  type = string
}

variable "base_dir" {
  type = string
}

variable "public_assets_bucket" {
  type = map(any)
}

variable "image_optimization_lambda_memory_size" {
  type = number
}

variable "image_optimization_ephemeral_storage_size" {
  type = number
}

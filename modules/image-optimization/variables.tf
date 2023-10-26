variable "runtime" {
  type = string
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

variable "public_assets_bucket" {
  type = map(any)
}

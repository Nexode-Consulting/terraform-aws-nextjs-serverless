variable "name" {
  type    = string
  default = "nextjs-template"
}

variable "enviroment" {
  type    = string
  default = "prod"
}

variable "base_domain" {
  type = string
}

variable "runtime" {
  type    = string
  default = "nodejs16.x"
}

variable "logs_retention" {
  type    = number
  default = 30
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "global_region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_memory_size" {
  type    = number
  default = 2048
}
provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "global_region"
  region = var.global_region
}

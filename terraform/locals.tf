locals {
  repo = "${var.name}-${var.enviroment}"

  env_prefix = var.enviroment == "prod" ? "" : "${var.enviroment}."
  subdomain  = "${local.env_prefix}${var.name}.${var.base_domain}"

  # server_domain = "server.${local.subdomain}"
}

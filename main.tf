terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
  }
}

variable "sleep_seconds" {
  type    = number
  default = 30
}

variable "delay_url" {
  type    = string
  default = ""
}

locals {
  effective_delay_url = var.delay_url != "" ? var.delay_url : "http://host.docker.internal:8089/?seconds=${var.sleep_seconds}"
}

data "http" "slow_plan" {
  url = local.effective_delay_url
}

resource "terraform_data" "marker" {
  input = sha256(data.http.slow_plan.response_body)
}

output "marker" {
  value = terraform_data.marker.output
}

terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
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

resource "time_sleep" "operation_delay" {
  create_duration  = "${var.sleep_seconds}s"
  destroy_duration = "${var.sleep_seconds}s"

  triggers = {
    plan_body_hash = sha256(data.http.slow_plan.response_body)
  }
}

resource "terraform_data" "marker" {
  input = {
    plan_body_hash = sha256(data.http.slow_plan.response_body)
    delay_id       = time_sleep.operation_delay.id
  }
}

output "marker" {
  value = terraform_data.marker.output
}

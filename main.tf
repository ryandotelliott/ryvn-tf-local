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

variable "fail_apply" {
  type    = bool
  default = false
}

variable "failure_nonce" {
  type    = string
  default = "0"
}

variable "apply_failure_sleep_seconds" {
  type    = number
  default = 30
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

resource "terraform_data" "apply_failure" {
  input = {
    delay_id = time_sleep.operation_delay.id
  }

  triggers_replace = {
    fail_apply    = var.fail_apply
    failure_nonce = var.failure_nonce
  }

  provisioner "local-exec" {
    when        = create
    interpreter = ["/bin/sh", "-c"]
    command     = var.fail_apply ? "sleep ${var.apply_failure_sleep_seconds}; echo forced apply failure >&2; exit 42" : "true"
  }
}

output "marker" {
  value = terraform_data.marker.output
}

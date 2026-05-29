terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

variable "sleep_seconds" {
  type    = number
  default = 30
}

data "external" "slow_plan" {
  program = [
    "bash",
    "-c",
    "sleep ${var.sleep_seconds}; echo '{\"result\":\"done\"}'",
  ]
}

resource "terraform_data" "marker" {
  input = data.external.slow_plan.result.result
}

output "marker" {
  value = terraform_data.marker.output
}

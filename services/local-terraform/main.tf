variable "fail_apply" {
  type        = bool
  default     = false
  description = "Set to true to force the apply to fail."
}

variable "change_nonce" {
  type        = string
  default     = "0"
  description = "Change this value to force a new no-op apply attempt."
}

resource "terraform_data" "noop" {
  input = {
    status       = var.fail_apply ? "failure requested" : "success"
    change_nonce = var.change_nonce
  }

  triggers_replace = {
    fail_apply   = tostring(var.fail_apply)
    change_nonce = var.change_nonce
  }

  lifecycle {
    postcondition {
      condition     = !var.fail_apply || self.output.status == "success"
      error_message = "forced local Terraform failure"
    }
  }
}

output "marker" {
  value = terraform_data.noop.output
}

output "success" {
  value = !var.fail_apply
}

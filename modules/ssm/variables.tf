variable "github_app" {
  description = "GitHub app parameters, see your github app. Ensure the key is the base64-encoded `.pem` file (the output of `base64 app.private-key.pem`, not the content of `private-key.pem`)."
  type = object({
    key_base64 = optional(string)
    key_base64_ssm = optional(object({
      arn  = string
      name = string
    }))
    id = optional(string)
    id_ssm = optional(object({
      arn  = string
      name = string
    }))
    webhook_secret = optional(string)
    webhook_secret_ssm = optional(object({
      arn  = string
      name = string
    }))
  })
}

variable "path_prefix" {
  description = "The path prefix used for naming resources"
  type        = string
}

variable "kms_key_arn" {
  description = "Optional CMK Key ARN to be used for Parameter Store."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags that will be added to created resources. By default resources will be tagged with name and environment."
  type        = map(string)
  default     = {}
}

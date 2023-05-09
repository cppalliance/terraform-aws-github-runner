variable "github_app" {
  description = "GitHub for API usages."

  type = object({
    id         = string
    key_base64 = string
  })
}

variable "environment" {
  type    = string
  default = null
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

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

variable "aws_default_vpc" {
  type    = string
  default = null
}

variable "aws_default_route_table" {
  type    = string
  default = null
}

variable "aws_default_cidr_range" {
  type    = string
  default = null
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types"
  type        = list(string)

  default = [
    "t3.micro",
    "m7i-flex.large"
  ]
}

variable "instance_names" {
  description = "EC2 instance names"
  type        = list(string)

  default = [
    "app-server-1",
    "app-server-2"
  ]
}

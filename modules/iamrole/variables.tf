variable "iam_policy_name" {
  type    = string
  default = "webserver-s3access-policy"
}

variable "role_name" {
  type    = string
  default = "Webserver-s3-role"
}
variable "instance_profile_name" {
  description = "Instance profile name for Auto scaling Group"
  default = "Webserverprofile"
}
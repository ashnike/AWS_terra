variable "domain_name" {
  type = string
  default = "test.pinakaops.in"
}

variable "cloudfront_domain_name" {
  description = "cloudfront_dns_value"
}
variable "cloudfront_hosted_zone_id" {
  description = "zone_id_value"
}
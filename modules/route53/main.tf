resource "aws_route53_zone" "example" {
  name = var.domain_name
}

# Create an ALB DNS record within the hosted zone
resource "aws_route53_record" "cloudfront_dns_record" {
  zone_id = aws_route53_zone.example.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
resource "null_resource" "write_nameservers" {
  depends_on = [aws_route53_zone.example]

  provisioner "local-exec" {
    command = <<-EOT
      echo "${join("\n", aws_route53_zone.example.name_servers)}" > nameservers.txt
    EOT
  }
}

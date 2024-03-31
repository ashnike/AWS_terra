resource "aws_acm_certificate" "hello_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "selected" {
  zone_id = var.route53_zone_id
}

locals {
  domain_validation_options = [
    for option in aws_acm_certificate.hello_certificate.domain_validation_options : {
      name    = option.resource_record_name
      type    = option.resource_record_type
      ttl     = 60
      records = [option.resource_record_value]
    }
  ]
}

resource "aws_route53_record" "cert_validation_record" {
  count = length(local.domain_validation_options)

  zone_id         = data.aws_route53_zone.selected.zone_id
  name            = local.domain_validation_options[count.index].name
  type            = local.domain_validation_options[count.index].type
  ttl             = local.domain_validation_options[count.index].ttl
  records         = local.domain_validation_options[count.index].records
  allow_overwrite = true
}

#resource "aws_acm_certificate_validation" "cert-validation" {
  ##depends_on = [aws_acm_certificate.hello_certificate]
  #certificate_arn         = aws_acm_certificate.hello_certificate.arn
  #validation_record_fqdns = [for record in aws_route53_record.cert-validation-record : record.fqdn]
#}
#resource "aws_route53_record" "cert-validation-record" {
  #for_each = {
    #for dvo in aws_acm_certificate.hello_certificate.domain_validation_options : dvo.domain_name => {
      #name   = dvo.resource_record_name
      #record = dvo.resource_record_value
      #type   = dvo.resource_record_type
    #}
  #}

  #allow_overwrite = true
  #name            = each.value.name
  #records         = [each.value.record]
  #ttl             = 60
  #type            = each.value.type
 #zone_id         = var.route53_zone_id
#}
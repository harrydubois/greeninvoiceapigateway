# ACM Certificate for the API Gateway domain
resource "aws_acm_certificate" "api-cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Hosted zone of the API Gateway domain
data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone
  private_zone = false
}

# Automagically create domain validation records for the certificate
resource "aws_route53_record" "dns_records" {
  for_each = {
    for dvo in aws_acm_certificate.api-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.api-cert.arn
  validation_record_fqdns = []
}

# A record for the API Gateway domain
resource "aws_route53_record" "api_dns_record" {
  name    = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.hosted_zone.id

  alias {
    evaluate_target_health = false
    name                   = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name_configuration[0].hosted_zone_id
  }

}
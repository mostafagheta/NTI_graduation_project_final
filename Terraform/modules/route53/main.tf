data "aws_route53_zone" "main" {
  name         = var.hosted_zone_name
  private_zone = false
}


# Create Route53 alias record for the NLB
resource "aws_route53_record" "nlb_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.nlb_dns_name
    zone_id                = var.nlb_zone_id
    evaluate_target_health = true
  }
}
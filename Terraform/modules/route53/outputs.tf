
output "domain_name" {
  description = "Domain name configured"
  value       = var.domain_name
}

output "route53_record_fqdn" {
  description = "FQDN of the Route53 record"
  value       = aws_route53_record.nlb_alias.fqdn
}

output "route53_record_name" {
  description = "Name of the Route53 record"
  value       = aws_route53_record.nlb_alias.name
}

output "nlb_dns_name" {
  description = "DNS name of the NLB"
  value       = var.nlb_dns_name
}
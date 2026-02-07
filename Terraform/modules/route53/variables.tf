variable "domain_name" {
  description = "Domain name for the NLB"
  type        = string
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name"
  type        = string
}

variable "nlb_dns_name" {
  description = "DNS name of the NLB"
  type        = string
}

variable "nlb_zone_id" {
  description = "Zone ID of the NLB"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate to use for the NLB"
  type        = string
}
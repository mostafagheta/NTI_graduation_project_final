variable "argocd_admin_password" {
  description = "Initial Argo CD admin password"
  type        = string
}

variable "route53_zone_name" {
  description = "Route53 hosted zone domain name (e.g. example.com)"
  type        = string
}

variable "route53_zone_id" {
  description = "Optional: Route53 hosted zone id. If empty, the provisioner will look it up using AWS CLI."
  type        = string
  default     = ""
}

variable "route53_record_name" {
  description = "DNS record name to create/alias (defaults to zone apex when empty)"
  type        = string
  default     = ""
}

variable "ingress_namespace" {
  description = "Namespace where ingress-nginx is installed"
  type        = string
  default     = "ingress-nginx"
}

variable "ingress_label_selector" {
  description = "Label selector used to find the ingress service"
  type        = string
  default     = "app.kubernetes.io/name=ingress-nginx"
}

variable "create_namespace" {
  description = "Whether helm releases should create namespaces"
  type        = bool
  default     = true
}

variable "project_name" {
  description = "Project name used to derive predictable resource names (e.g. lb name)"
  type        = string
}

variable "lb_name" {
  description = "Optional: explicit load balancer name to use for the ingress NLB. If empty, derived from project_name."
  type        = string
  default     = ""
}


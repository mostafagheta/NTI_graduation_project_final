variable "create_eks" {
  type        = bool
  description = "Controls if EKS resources should be created"
  default     = true
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region"
}
variable "project_name" {
  type        = string
  description = "Name prefix for all resources"
  default     = "my-eks"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "192.168.0.0/16"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default = [
    "192.168.0.0/18",
    "192.168.64.0/18"
  ]
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default = [
    "192.168.128.0/18",
    "192.168.192.0/18"
  ]
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["eu-central-1a", "eu-central-1b"]
}
variable "cluster_name" {
  type        = string
  default     = "my-eks"
  description = "Name of the EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = ""
}

variable "private_subnets_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS worker nodes"
  default     = []
}

variable "public_subnets_ids" {
  type        = list(string)
  description = "Public subnet IDs for EKS load balancers"
  default     = []
}

variable "eks_version" {
  type    = string
  default = "1.34"
}

variable "node_group_name" {
  type    = string
  default = "eks-workers"
}

variable "node_group_instance_types" {
  type    = list(string)
  default = ["m7i-flex.large"]
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 3
}

variable "min_capacity" {
  type    = number
  default = 2
}
variable "secret_name" {
  description = "Name of the secret"
  type        = string
  default     = "my-db-secret-credentials"
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = "Database credentials"
}

variable "secret_values" {
  description = "Key-value map to store as secret"
  type        = map(string)
}

variable "tags" {
  description = "Tags for the secret"
  type        = map(string)
  default = {
    Environment = "production"
  }
}
variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster. If not provided, it will be obtained from the EKS module."
  type        = string
  default     = null
}

variable "autoscaler_namespace" {
  description = "Namespace for Cluster Autoscaler"
  type        = string
  default     = "kube-system"
}

variable "autoscaler_version" {
  description = "Cluster Autoscaler version (should match k8s version)"
  type        = string
  default     = "1.34.0"
}

variable "autoscaler_image_tag" {
  description = "Cluster Autoscaler image tag"
  type        = string
  default     = "v1.34.0"
}

variable "route53_zone_name" {
  description = "Route53 hosted zone domain name (e.g. example.com)"
  type        = string
  default     = "marwanalaa.cloud"
}

variable "route53_zone_id" {
  description = "Optional: Route53 hosted zone id. If empty, the provisioner will look it up using AWS CLI."
  type        = string
  default     = "Z07916332BEWRI26NDYCG"
}

variable "route53_record_name" {
  description = "DNS record name to create/alias (defaults to zone apex when empty)"
  type        = string
  default     = "app.marwanalaa.cloud"
}
/*
variable "repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "nti-project-repo"
}
variable "image_tag_mutability" {
  description = "IMMUTABLE or MUTABLE"
  type        = string
  default     = "IMMUTABLE"
}
variable "scan_on_push" {
  description = "Enable image scan on push"
  type        = bool
  default     = true
}
variable "ecr_tags" {
  description = "Tags for ECR repository"
  type        = map(string)
  default = {
    Environment = "production"
    owner       = "mostafagheta"
    Project     = "eks-ingress"
    Service     = "ecr-repo"
  }
}*/


variable "namespace" {
  description = "Namespace for AWS Load Balancer Controller"
  type        = string
  default     = "kube-system"
}

variable "chart_version" {
  description = "Helm chart version for AWS Load Balancer Controller"
  type        = string
  default     = "1.7.2"
}
variable "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster"
  type        = string
  default = ""
}


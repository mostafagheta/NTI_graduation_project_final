variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default = "my-eks"
}

variable "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS is deployed"
  type        = string

}

variable "region" {
  description = "AWS region"
  type        = string
  default = "eu-central-1"
}

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

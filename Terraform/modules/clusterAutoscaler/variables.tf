variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the OIDC Provider"
  type        = string
}

variable "autoscaler_namespace" {
  description = "The namespace where the Cluster Autoscaler will be installed"
  type        = string
  default     = "kube-system"
}

variable "autoscaler_image_tag" {
  description = "The image tag for the Cluster Autoscaler deployment"
  type        = string
  default     = "v1.34.0"
}

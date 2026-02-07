variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "private_subnets_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS worker nodes"
}

variable "public_subnets_ids" {
  type        = list(string)
  description = "Public subnet IDs for EKS load balancers"
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
  default = ["t3.micro"]
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
  default = 1
}
variable "bastion_sg_id" {
  type        = string
  description = "Security group ID of the bastion host for SSH access to nodes"
  default     = ""
}

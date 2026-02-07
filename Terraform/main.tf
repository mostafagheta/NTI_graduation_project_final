module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  azs                  = var.azs
}

module "eks" {
  source = "./modules/eks"

  cluster_name              = var.project_name
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr                  = var.vpc_cidr
  private_subnets_ids       = module.vpc.private_subnets_ids
  public_subnets_ids        = module.vpc.public_subnets_ids
  eks_version               = var.eks_version
  node_group_name           = var.node_group_name
  node_group_instance_types = var.node_group_instance_types
  desired_capacity          = var.desired_capacity
}

module "db_secret" {
  source        = "./modules/asm"
  secret_name   = var.secret_name
  description   = var.description
  secret_values = var.secret_values
  tags          = var.tags
}

locals {
  oidc_provider_arn = var.oidc_provider_arn != null ? var.oidc_provider_arn : module.eks.oidc_provider_arn
}

module "clusterAutoscaler" {
  source = "./modules/clusterAutoscaler"

  cluster_name         = module.eks.cluster_name
  region               = var.region
  oidc_provider_arn    = local.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider
  autoscaler_namespace = "kube-system"

  providers = {
    kubectl = kubectl.cluster_autoscaler
  }

  depends_on = [
    module.eks,
    module.eks.node_group_arns
  ]
}

module "alb_ingress_controller" {
  source = "./modules/alb_controller"

  cluster_name              = module.eks.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id                    = module.vpc.vpc_id
  region                    = "eu-central-1"
  depends_on = [ module.eks , module.vpc ]
}


resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.2.0"

  create_namespace = true
  depends_on = [
    module.eks,
    module.eks.eks_node_group_arn
  ]
}


resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.10.5"

  create_namespace = true
  depends_on = [
    module.eks,
    module.eks.eks_node_group_arn
  ]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.1"

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  set {
    name  = "args[1]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }

  depends_on = [
    module.eks,
    module.eks.eks_node_group_arn
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.resources.requests.cpu"
    value = "250m"
  }

  set {
    name  = "server.resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "server.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "server.resources.limits.memory"
    value = "1Gi"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    module.eks,
    module.eks.eks_node_group_arn
  ]

}


#terraform apply -var='secret_values={"username":"admin","password":"SuperSecret123!"}'
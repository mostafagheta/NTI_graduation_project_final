resource "aws_iam_policy" "alb_controller" {
  name   = "${var.cluster_name}-alb-controller-policy"
  policy = file("${path.module}/iam_policy.json")
}

module "alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name = "${var.cluster_name}-alb-controller"

  oidc_providers = {
    eks = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:aws-load-balancer-controller"]
    }
  }

  role_policy_arns = {
    alb = aws_iam_policy.alb_controller.arn
  }
}
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.namespace
    
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb_irsa.iam_role_arn
      "meta.helm.sh/release-name" = "aws-load-balancer-controller"
      "meta.helm.sh/release-namespace" = var.namespace
    }
    
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = var.namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.chart_version
  
  values = [
    <<-EOT
    serviceAccount:
      create: false
      name: ${kubernetes_service_account.alb_controller.metadata[0].name}
      annotations:
        eks.amazonaws.com/role-arn: ${module.alb_irsa.iam_role_arn}
    EOT
  ]

  set {
    name  = "clusterName"
    value = var.cluster_name
    type  = "string"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
    type  = "string"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
    type  = "string"
  }

  set {
    name  = "region"
    value = var.region
    type  = "string"
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
    type  = "string"
  }

  depends_on = [
    kubernetes_service_account.alb_controller
  ]
}

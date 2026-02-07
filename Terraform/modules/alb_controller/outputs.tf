output "service_account_name" {
  value = kubernetes_service_account.alb_controller.metadata[0].name
}

output "iam_role_arn" {
  value = module.alb_irsa.iam_role_arn
}

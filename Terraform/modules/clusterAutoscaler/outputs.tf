output "iam_role_arn" {
  description = "The ARN of the IAM role for the Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "iam_policy_arn" {
  description = "The ARN of the IAM policy for the Cluster Autoscaler"
  value       = aws_iam_policy.cluster_autoscaler.arn
}

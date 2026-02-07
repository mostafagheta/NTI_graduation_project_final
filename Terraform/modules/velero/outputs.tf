output "velero_bucket" {
  value = aws_s3_bucket.velero.bucket
}

output "velero_role_arn" {
  value = aws_iam_role.velero.arn
}

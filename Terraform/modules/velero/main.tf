resource "aws_s3_bucket" "velero" {
  bucket = var.bucket_name

  tags = {
    Name = "velero-backups"
  }
}

resource "aws_s3_bucket_versioning" "velero" {
  bucket = aws_s3_bucket.velero.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_iam_policy" "velero" {
  name = "velero-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          aws_s3_bucket.velero.arn,
          "${aws_s3_bucket.velero.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:CreateTags"
        ]
        Resource = "*"
      }
    ]
  })
}
locals {
  oidc_host = replace(var.oidc_provider_url, "https://", "")
}
resource "aws_iam_role" "velero" {
  name = "velero-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_host}:sub" = "system:serviceaccount:${var.namespace}:velero"
          "${local.oidc_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "velero" {
  role       = aws_iam_role.velero.name
  policy_arn = aws_iam_policy.velero.arn
}

resource "helm_release" "velero" {
  name       = "velero"
  namespace  = var.namespace
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = "5.4.0"

  create_namespace = true

  values = [yamlencode({
    serviceAccount = {
      create = true
      name   = "velero"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.velero.arn
      }
    }

    configuration = {
      provider = "aws"
      backupStorageLocation = {
        name = "default"
        bucket = var.bucket_name
        config = {
          region = var.region
        }
      }

      volumeSnapshotLocation = {
        name = "default"
        config = {
          region = var.region
        }
      }
    }

    initContainers = [{
      name  = "velero-plugin-for-aws"
      image = "velero/velero-plugin-for-aws:v1.9.0"
      volumeMounts = [{
        mountPath = "/target"
        name      = "plugins"
      }]
    }]
  })]
}

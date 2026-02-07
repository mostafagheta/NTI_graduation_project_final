data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "ClusterAutoscalerPolicy-${var.cluster_name}"
  description = "Policy for Cluster Autoscaler to manage ASG"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "cluster_autoscaler" {
  name = "ClusterAutoscalerRole-${var.cluster_name}"

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
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:${var.autoscaler_namespace}:cluster-autoscaler"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "kubectl_manifest" "cluster_autoscaler_sa" {
  depends_on = [
    aws_iam_role.cluster_autoscaler,
    aws_iam_role_policy_attachment.cluster_autoscaler
  ]
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: cluster-autoscaler
      namespace: ${var.autoscaler_namespace}
      annotations:
        eks.amazonaws.com/role-arn: ${aws_iam_role.cluster_autoscaler.arn}
      labels:
        k8s-addon: cluster-autoscaler.addons.k8s.io
        k8s-app: cluster-autoscaler
  YAML
}

resource "kubectl_manifest" "cluster_autoscaler_cluster_role" {
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: cluster-autoscaler
      labels:
        k8s-addon: cluster-autoscaler.addons.k8s.io
        k8s-app: cluster-autoscaler
    rules:
      - apiGroups: [""]
        resources: ["events", "endpoints"]
        verbs: ["create", "patch"]
      - apiGroups: [""]
        resources: ["pods/eviction"]
        verbs: ["create"]
      - apiGroups: [""]
        resources: ["pods/status"]
        verbs: ["update"]
      - apiGroups: [""]
        resources: ["endpoints"]
        resourceNames: ["cluster-autoscaler"]
        verbs: ["get", "update"]
      - apiGroups: [""]
        resources: ["nodes"]
        verbs: ["watch", "list", "get", "update"]
      - apiGroups: [""]
        resources:
          - "namespaces"
          - "pods"
          - "services"
          - "replicationcontrollers"
          - "persistentvolumeclaims"
          - "persistentvolumes"
        verbs: ["watch", "list", "get"]
      - apiGroups: ["extensions"]
        resources: ["replicasets", "daemonsets"]
        verbs: ["watch", "list", "get"]
      - apiGroups: ["policy"]
        resources: ["poddisruptionbudgets"]
        verbs: ["watch", "list"]
      - apiGroups: ["apps"]
        resources: ["statefulsets", "replicasets", "daemonsets"]
        verbs: ["watch", "list", "get"]
      - apiGroups: ["storage.k8s.io"]
        resources: ["storageclasses", "csinodes", "csidrivers", "csistoragecapacities"]
        verbs: ["watch", "list", "get"]
      - apiGroups: ["batch", "extensions"]
        resources: ["jobs"]
        verbs: ["get", "list", "watch", "patch"]
      - apiGroups: ["coordination.k8s.io"]
        resources: ["leases"]
        verbs: ["create"]
      - apiGroups: ["coordination.k8s.io"]
        resourceNames: ["cluster-autoscaler"]
        resources: ["leases"]
        verbs: ["get", "update"]
  YAML
}

resource "kubectl_manifest" "cluster_autoscaler_cluster_role_binding" {
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: cluster-autoscaler
      labels:
        k8s-addon: cluster-autoscaler.addons.k8s.io
        k8s-app: cluster-autoscaler
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-autoscaler
    subjects:
      - kind: ServiceAccount
        name: cluster-autoscaler
        namespace: ${var.autoscaler_namespace}
  YAML

  depends_on = [kubectl_manifest.cluster_autoscaler_cluster_role]
}

resource "kubectl_manifest" "cluster_autoscaler_role" {
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: cluster-autoscaler
      namespace: ${var.autoscaler_namespace}
      labels:
        k8s-addon: cluster-autoscaler.addons.k8s.io
        k8s-app: cluster-autoscaler
    rules:
      - apiGroups: [""]
        resources: ["configmaps"]
        verbs: ["create", "list", "watch"]
      - apiGroups: [""]
        resources: ["configmaps"]
        resourceNames: ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
        verbs: ["delete", "get", "update", "watch"]
  YAML
}


resource "kubectl_manifest" "cluster_autoscaler_role_binding" {
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: cluster-autoscaler
      namespace: ${var.autoscaler_namespace}
      labels:
        k8s-addon: cluster-autoscaler.addons.k8s.io
        k8s-app: cluster-autoscaler
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: cluster-autoscaler
    subjects:
      - kind: ServiceAccount
        name: cluster-autoscaler
        namespace: ${var.autoscaler_namespace}
  YAML

  depends_on = [kubectl_manifest.cluster_autoscaler_role]
}

resource "kubectl_manifest" "cluster_autoscaler_deployment" {
  yaml_body = <<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: cluster-autoscaler
      namespace: ${var.autoscaler_namespace}
      labels:
        app: cluster-autoscaler
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: cluster-autoscaler
      template:
        metadata:
          labels:
            app: cluster-autoscaler
          annotations:
            prometheus.io/scrape: "true"
            prometheus.io/port: "8085"
        spec:
          priorityClassName: system-cluster-critical
          securityContext:
            runAsNonRoot: true
            runAsUser: 65534
            fsGroup: 65534
            seccompProfile:
              type: RuntimeDefault
          serviceAccountName: cluster-autoscaler
          containers:
            - image: registry.k8s.io/autoscaling/cluster-autoscaler:${var.autoscaler_image_tag}
              name: cluster-autoscaler
              resources:
                limits:
                  cpu: 100m
                  memory: 600Mi
                requests:
                  cpu: 100m
                  memory: 600Mi
              command:
                - ./cluster-autoscaler
                - --v=4
                - --stderrthreshold=info
                - --cloud-provider=aws
                - --skip-nodes-with-local-storage=false
                - --expander=least-waste
                - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.cluster_name}
                - --balance-similar-node-groups
                - --skip-nodes-with-system-pods=false
              volumeMounts:
                - name: ssl-certs
                  mountPath: /etc/ssl/certs/ca-certificates.crt
                  readOnly: true
              imagePullPolicy: Always
              securityContext:
                allowPrivilegeEscalation: false
                capabilities:
                  drop:
                    - ALL
                readOnlyRootFilesystem: true
          volumes:
            - name: ssl-certs
              hostPath:
                path: /etc/ssl/certs/ca-bundle.crt
  YAML

  depends_on = [
    kubectl_manifest.cluster_autoscaler_sa,
    kubectl_manifest.cluster_autoscaler_cluster_role_binding,
    kubectl_manifest.cluster_autoscaler_role_binding
  ]
}
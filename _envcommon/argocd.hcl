terraform {
  source = "tfr:///terraform-module/release/helm?version=3.1.1"
}

generate "grafana_creds" {
  path      = "grafana-secrets.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "random_password" "grafana" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = "grafana-admin-credentials"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  data = {
    admin-password = random_password.grafana.result
    admin-user     = "admin"
  }
}
EOF
}

inputs = {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    <<-EOF
    server:
      extraArgs:
        - --insecure
      extraObjects:
        - apiVersion: argoproj.io/v1alpha1
          kind: Application
          metadata:
            name: root-application
            namespace: argocd
          spec:
            project: default
            source:
              repoURL: 'https://github.com/Rivce06/k8s-configs.git'
              targetRevision: HEAD
              path: bootstrap
            destination:
              server: 'https://kubernetes.default.svc'
              namespace: argocd
            syncPolicy:
              automated:
                prune: true
                selfHeal: true
    EOF
  ]
}
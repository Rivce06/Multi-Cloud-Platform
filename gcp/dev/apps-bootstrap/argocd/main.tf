terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.chart_version

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
}

terraform {
  required_version = ">= 1.10.0" 

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.chart_version

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "configs.cm.kubernetes.resource.patch.serverSideApply"
    value = "true"
  }
}

resource "kubernetes_manifest" "root_app" {
  depends_on = [helm_release.argocd]

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "root-app"
      "namespace" = "argocd"
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = "https://github.com"
        "targetRevision" = "main"
        "path"           = "bootstrap"
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = "argocd"
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
        "syncOptions" = ["CreateNamespace=true"]
      }
    }
  }
}

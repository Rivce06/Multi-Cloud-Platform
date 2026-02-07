terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.0" # Versión estable en 2026
    }
  }
}

provider "kubernetes" {
  host                   = "https://${var.host}"
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}

resource "kubernetes_manifest" "rbac_resources" {
  count = length(var.manifests)

  manifest = yamldecode(var.manifests[count.index])
}
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${var.host}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}

resource "kubernetes_manifest" "rbac_resources" {
  count = length(var.manifests)

  manifest = yamldecode(var.manifests[count.index])
}

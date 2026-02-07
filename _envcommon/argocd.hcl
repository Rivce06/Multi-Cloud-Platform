terraform {
  source = "tfr:///hashicorp/helm//modules/release?version=3.0.1"
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
  service:
    type: ClusterIP
  extraArgs:
    - --insecure
EOF
  ]
}
terraform {
  source = "tfr:///terraform-module/release/helm?version=2.9.1"
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
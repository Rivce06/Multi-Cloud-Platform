include "root" {
  path   = find_in_parent_folders("root.hcl")
}

locals {
  project_id = include.root.inputs.gcp_project_id
}

dependency "gke" {
  config_path = "../../gke/cluster"

  mock_outputs = {
    name     = "test-gke"
    location = "us-central1"
  }

  mock_outputs_allowed_terraform_commands = [
    "validate",
    "plan"
  ]
}

terraform {
  source = "tfr:///terraform-google-modules/kubernetes-engine/google//modules/kubernetes-manifest?version=43.0.0"
}

inputs = {
  project_id = local.project_id
  location   = dependency.gke.outputs.location
  cluster_name = dependency.gke.outputs.name

  manifests = [
    <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-manager
  namespace: argocd
  annotations:
    iam.gke.io/gcp-service-account: gke-workloads@${local.gcp_project_id}.iam.gserviceaccount.com
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-manager-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: argocd-manager
  namespace: argocd
EOF
  ]
}
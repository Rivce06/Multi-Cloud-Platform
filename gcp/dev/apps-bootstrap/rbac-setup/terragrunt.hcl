include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "."
}

dependency "gke" {
  config_path = "../../gke/cluster"
  
  mock_outputs = {
    endpoint       = "1.2.3.4"
    ca_certificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCg=="
  }
  mock_outputs_allowed_terraform_commands = ["validate"]
}

inputs = {
  host                   = dependency.gke.outputs.endpoint
  cluster_ca_certificate = dependency.gke.outputs.ca_certificate
  
  manifests = [
    <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
EOF
    ,
    <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bootstrap-manager
  namespace: argocd
  annotations:
    iam.gke.io/gcp-service-account: gke-workloads@${include.root.locals.gcp_project_id}.iam.gserviceaccount.com
EOF
    ,
    <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: bootstrap-manager-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: bootstrap-manager
  namespace: argocd
EOF
  ]
}
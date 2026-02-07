variable "host" {
  description = "Cluster Endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "CA Certificate"
  type        = string
}

variable "chart_version" {
  description = "Chart Version"
  type        = string
  default     = "7.7.0"
}

variable "argocd_name" {
  description = "Release name"
  type        = string
  default     = "argocd"
}
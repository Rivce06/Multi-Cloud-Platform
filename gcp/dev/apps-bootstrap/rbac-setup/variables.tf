variable "host" {
  description = "GKE cluster Endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "CA Certificate"
  type        = string
}

variable "manifests" {
  description = "YMAL list"
  type        = list(string)
}
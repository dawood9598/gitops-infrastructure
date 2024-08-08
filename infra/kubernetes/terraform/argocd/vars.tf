variable "kubeconfig" {
  type = string
  default = "~/.kube/config"
}

variable "namespace" {
  type = string
  default = "argocd"
}

variable "chart_version" {
  description = "The version of the Argo CD Helm chart"
  type        = string
  default = "7.4.1"
}



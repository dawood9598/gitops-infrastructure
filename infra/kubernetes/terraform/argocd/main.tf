resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd"{
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    =  var.chart_version
  namespace  =  kubernetes_namespace.argocd.metadata[0].name
}

# This resource defines an Argo CD Application that tracks a directory containing multiple Argo CD applications.
resource "kubernetes_manifest" "argo_cd_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "argo-cd-applications"
      namespace = "argocd"
    }
    spec = {
      project  = "default"
      source = {
        repoURL        = "https://github.com/dawood9598/gitops-infrastructure.git"
        targetRevision = "HEAD"
        path           = "infra/kubernetes/argocd/applications"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
    }
  }
}

#This resource creates a project for CI CD applications on Argo
resource "kubernetes_manifest" "argo_cd_project_ci_cd" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "ci-cd"
      namespace = "argocd"
    }
    spec = {
      description = "This is an Argo CD project to manage CI CD pipelines."
      sourceRepos = ["*"]
      destinations = [
        {
          server    = "https://kubernetes.default.svc"
          namespace = "*"
        }
      ]
      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
      namespaceResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
    }
  }
}

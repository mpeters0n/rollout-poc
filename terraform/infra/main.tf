locals {
  app_name = "nginx-ingress"
}

provider "kubernetes" {
  config_path = "~/kind.kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "~/kind.kubeconfig"
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name = local.app_name
  namespace = kubernetes_namespace.this.metadata.0.name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"

  values = [ templatefile("${path.module}/ingress-nginx-values.yaml.tpl",
    {
      namespace = kubernetes_namespace.this.metadata.0.name
    })
  ]
}

# LoadBalancer support for kind
resource "kubernetes_manifest" "metallb_native" {
  manifest = yamldecode(file("${path.module}/metallb-native.yaml"))
}

resource "kubernetes_manifest" "metallb_config" {
  manifest = yamldecode(file("${path.module}/metallb-conf.yaml"))
}

# Install argo-rollouts
resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo-rollouts"
  }
}

resource "kubernetes_manifest" "argo_rollouts" {
  manifest = yamldecode(file("${path.module}/argo-rollout-install.yaml"))
}


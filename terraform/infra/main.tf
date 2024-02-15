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

# Install prometheus-operator
#resource "helm_release" "prometheus" {
#  name = local.app_name
#  namespace = kubernetes_namespace.this.metadata.0.name
#  repository = "https://prometheus-community.github.io/helm-charts"
#  chart = "kube-prometheus-stack"
#
#  values = [ templatefile("${path.module}/prometheus-values.yaml.tpl",
#    {
#      namespace = kubernetes_namespace.this.metadata.0.name
#    })
#  ]
#}

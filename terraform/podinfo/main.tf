#
# Example deployment from:
#
# https://github.com/fluxcd/flagger//kustomize/podinfo?ref=main
#
locals {
  app_name = "podinfo"
  app_team = "devops"
  env      = "dev"
}

provider "kubernetes" {
  config_path = "~/kind.kubeconfig"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = "podinfo"
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = local.app_name
    namespace = kubernetes_namespace.this.metadata.0.name
  }

  timeouts {
    create = "3m"
  }

  spec {
    # Managed by argo rollout
    replicas = 0

    selector {
      match_labels = {
        "app" = local.app_name
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = local.app_name
          "app" = local.app_name
        }
      }
      spec {
        container {
          image = "ghcr.io/stefanprodan/podinfo:6.0.2"
          name  = local.app_name
          command = [ "./podinfo", "--port=9898", "--port-metrics=9797", "--grpc-port=9999", "--grpc-service-name=podinfo", "--level=info", "--random-delay=false", "--random-error=false" ]

          resources {
            limits = {
              cpu    = "2000m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "1000m"
              memory = "64Mi"
            }
          }
          port {
            name = "http"
            container_port = 9898
          }
          port {
            name = "http-metrics"
            container_port = 9797
          }
          port {
            name = "grpc"
            container_port = 9999
          }
          readiness_probe {
            http_get {
              path = "/healthz"
              port = 9898
            }
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = 9898
            }
          }
          env {
            name = "PODINFO_UI_COLOR"
            value = "#34577c"
          }
          env {
            name = "RESTART"
            value = "1"
          }
        }
      }
    }
  }
}

# Define the Rollout deployment
resource "kubernetes_manifest" "argo_rollout" {
  manifest = yamldecode(templatefile("${path.module}/podinfo-rollout.yaml", {
    app_name  = local.app_name
    namespace = kubernetes_namespace.this.metadata.0.name
  }))

  depends_on = [ kubernetes_deployment.this ]
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "this" {
  metadata {
    name = local.app_name
    namespace = kubernetes_namespace.this.metadata.0.name
  }
  spec {
    max_replicas = 4
    min_replicas = 2
    scale_target_ref {
      api_version = "argoproj.io/v1alpha1"
      kind = "Rollout"
      name = local.app_name
    }
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type = "Utilization"
          average_utilization = 99
        }
      }
    }
  }

  depends_on = [ kubernetes_manifest.argo_rollout ]
}

resource "kubernetes_service" "this" {
  metadata {
    name      = "${local.app_name}-stable"
    namespace = kubernetes_namespace.this.metadata.0.name

    annotations = {
      "argo-rollouts.argoproj.io/managed-by-rollouts" = "podinfo"
    }
  }
  spec {
    selector = {
      "app" = "${local.app_name}"
      "rollouts-pod-template-hash" = "7b5d5dd876"
    }
    port {
      name = "http"
      port = 9898
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "canary" {
  metadata {
    name      = "${local.app_name}-canary"
    namespace = kubernetes_namespace.this.metadata.0.name

    annotations = {
      "argo-rollouts.argoproj.io/managed-by-rollouts" = "podinfo"
    }
  }
  spec {
    selector = {
      "app" = "${local.app_name}"
      "rollouts-pod-template-hash" = "7b5d5dd876"
    }
    port {
      name = "http"
      port = 9898
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "this" {
  metadata {
    name = "${local.app_name}-ingress"
    namespace = kubernetes_namespace.this.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
#      "nginx.ingress.kubernetes.io/rewrite-target" = "$2"
    }
  }
  spec {
    rule {
      # Whitelist accepted endpoints 
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.this.metadata[0].name
              port {
                number = 9898
              }
            }
          }
        }
      }
    }
  }

  depends_on = [ kubernetes_service.this ]
}

#
# Example load generator from:
#
# From https://github.com/fluxcd/flagger//kustomize/tester?ref=main
#
locals {
  app_name = "flagger-loadtester"
  app_team = "devops"
  env      = "dev"

  namespace = "podinfo"
}

provider "kubernetes" {
  config_path = "~/kind.kubeconfig"
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = local.app_name
    namespace = local.namespace
  }

  timeouts {
    create = "3m"
  }

  spec {
    selector {
      match_labels = {
        "app" = local.app_name
      }
    }
    template {
      metadata {
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port" = "8080"
          "openservicemesh.io/inbound-port-exclusion-list" = "80, 8080"
        }
        labels = {
          "app.kubernetes.io/name" = local.app_name
          # Required for istio/kiali visualization
          "app" = local.app_name
        }
      }
      spec {
        container {
          image = "ghcr.io/fluxcd/flagger-loadtester:0.31.0"
          name  = local.app_name
          command = [ "./loadtester", "-port=8080", "-log-level=info", "-timeout=1h" ]

          resources {
            limits = {
              cpu    = "1000m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
          }
          security_context {
            read_only_root_filesystem = true
            run_as_user = 10001
          }
          port {
            name = "http"
            container_port = 8080
          }
          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
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

resource "kubernetes_service" "this" {
  metadata {
    name      = local.app_name
    namespace = local.namespace
  }
  spec {
    selector = {
      "app" = local.app_name
    }
    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }

    type = "ClusterIP"
  }
}

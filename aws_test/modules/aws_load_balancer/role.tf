resource "kubernetes_cluster_role" "this" {
  metadata {
    name = var.service_account_name

    labels = {
      "app.kubernetes.io/name"       = "${var.service_account_name}"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = var.service_account_name

    labels = {
      "app.kubernetes.io/name"       = "${var.service_account_name}"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata.0.name
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = var.service_account_name
    namespace = var.namespace
  }
}
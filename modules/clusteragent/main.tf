############################################################
# REQUIRED PROVIDERS
############################################################
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.2"
    }
  }
}


############################################################
# CREATE BASIC ELEMENTS FOR APPDYNAMICS
############################################################
resource "kubernetes_secret" "cluster-agent-secret" {
  metadata {
    name      = "cluster-agent-secret"
    namespace = var.namespace
  }

  data = {
    "controller-key" = var.appd_controller_key
    "api-user"       = "${var.appd_username}@${var.appd_account_name}:${var.appd_password}"
  }
}


resource "kubernetes_service_account" "appdynamics-operator" {
  metadata {
    name      = "appdynamics-operator"
    namespace = var.namespace
  }
}


resource "kubernetes_role" "appdynamics-operator" {
  metadata {
    name      = "appdynamics-operator"
    namespace = var.namespace
  }

  rule {
    api_groups     = [""]
    resources      = ["pods", "pods/log", "endpoints", "persistentvolumeclaims", "resourcequotas", "nodes", "events", "namespaces"]
    verbs          = ["get", "list", "watch"]
  }

  rule {
    api_groups     = [""]
    resources      = ["pods", "services", "configmaps", "secrets"]
    verbs          = ["*"]
  }

  rule {
    api_groups     = ["apps"]
    resources      = ["statefulsets"]
    verbs          = ["get", "list", "watch"]
  }

  rule {
    api_groups     = ["apps"]
    resources      = ["deployments", "replicasets", "daemonsets"]
    verbs          = ["*"]
  }

  rule {
    api_groups     = ["batch", "extensions"]
    resources      = ["jobs"]
    verbs          = ["get", "list", "watch"]
  }

  rule {
    api_groups     = ["metrics.k8s.io"]
    resources      = ["pods", "nodes"]
    verbs          = ["get", "list", "watch"]
  }

  rule {
    api_groups     = ["appdynamics.com"]
    resources      = ["*", "clusteragents", "infravizs", "adams", "clustercollectors"]
    verbs          = ["*"]
  }
}


resource "kubernetes_role_binding" "appdynamics-operator" {
  metadata {
    name      = "appdynamics-operator"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "appdynamics-operator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "appdynamics-operator"
    namespace = var.namespace
  }
}


resource "kubernetes_deployment" "appdynamics-operator" {
  metadata {
    name      = "appdynamics-operator"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "appdynamics-operator"
      }
    }

    template {
      metadata {
        labels = {
          name = "appdynamics-operator"
        }
      }

      spec {
        service_account_name = "appdynamics-operator"

        container {
          image = "docker.io/appdynamics/cluster-agent-operator:0.6.3"
          name  = "appdynamics-operator"

          port {
            container_port = 60000
            name = "metrics"
          }

          command = ["appdynamics-operator"]

          resources {
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }

          env {
            name = "WATCH_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "OPERATOR_NAME"
            value = "appdynamics-operator"
          }
        }
      }
    }
  }
}


resource "kubernetes_service_account" "appdynamics-cluster-agent" {
  metadata {
    name      = "appdynamics-cluster-agent"
    namespace = var.namespace
  }
}


resource "kubernetes_cluster_role" "appdynamics-cluster-agent" {
  metadata {
    name = "appdynamics-cluster-agent"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "endpoints", "persistentvolumeclaims", "resourcequotas", "nodes", "events", "namespaces", "services", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets", "statefulsets", "deployments", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["appdynamics.com"]
    resources  = ["*", "clusteragents", "clustercollectors"]
    verbs      = ["get", "list", "watch"]
  }
}


resource "kubernetes_cluster_role" "appdynamics-cluster-agent-instrumentation" {
  metadata {
    name = "appdynamics-cluster-agent-instrumentation"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/exec", "secrets", "configmaps"]
    verbs      = ["create", "update", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets", "statefulsets", "deployments", "replicasets"]
    verbs      = ["update"]
  }
}

resource "kubernetes_cluster_role_binding" "appdynamics-cluster-agent" {
  metadata {
    name = "appdynamics-cluster-agent"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "appdynamics-cluster-agent"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "appdynamics-cluster-agent"
    namespace = var.namespace
  }
}


resource "kubernetes_cluster_role_binding" "appdynamics-cluster-agent-instrumentation" {
  metadata {
    name = "appdynamics-cluster-agent-instrumentation"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "appdynamics-cluster-agent-instrumentation"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "appdynamics-cluster-agent"
    namespace = var.namespace
  }
}


resource "kubernetes_service_account" "appdynamics-infraviz" {
  metadata {
    name      = "appdynamics-infraviz"
    namespace = var.namespace
  }
}


resource "kubernetes_pod_security_policy" "appdynamics-infraviz" {
  metadata {
    name = "appdynamics-infraviz"
    annotations = {
      "seccomp.security.alpha.kubernetes.io/allowedProfileNames" = "*"
    }
  }
  spec {
    privileged                 = true
    allow_privilege_escalation = true

    allowed_capabilities = ["*"]

    host_network = true
    host_ipc     = true
    host_pid     = true
    host_ports   {
      min = 0
      max = 65535
    }

    volumes = ["*"]

    run_as_user {
      rule = "RunAsAny"
    }

    se_linux {
      rule = "RunAsAny"
    }

    supplemental_groups {
      rule = "RunAsAny"
    }

    fs_group {
      rule = "RunAsAny"
    }
  }
}


resource "kubernetes_cluster_role" "appdynamics-infraviz" {
  metadata {
    name = "appdynamics-infraviz"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "nodes", "events", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "deployments", "replicasets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch"]
  }
}


resource "kubernetes_cluster_role_binding" "appdynamics-infraviz" {
  metadata {
    name = "appdynamics-infraviz"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "appdynamics-infraviz"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "appdynamics-infraviz"
    namespace = var.namespace
  }
}

resource "kubernetes_role" "appdynamics-infraviz" {
  metadata {
    name      = "appdynamics-infraviz"
    namespace = var.namespace
  }

  rule {
    api_groups     = ["extensions"]
    resources      = ["podsecuritypolicies"]
    resource_names = ["appdynamics-infraviz"]
    verbs          = ["use"]
  }
}


resource "kubernetes_role_binding" "appdynamics-infraviz" {
  metadata {
    name      = "appdynamics-infraviz"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "appdynamics-infraviz"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "appdynamics-infraviz"
    namespace = var.namespace
  }
}


############################################################
# DEPLOY CRDS AND CUSTOM ELEMENTS
############################################################
resource "kubernetes_manifest" "clusteragents_crd" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1beta1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "name" = "clusteragents.appdynamics.com"
    }
    "spec" = {
      "group" = "appdynamics.com"
      "names" = {
        "kind" = "Clusteragent"
        "listKind" = "ClusteragentList"
        "plural" = "clusteragents"
        "singular" = "clusteragent"
      }
      "scope" = "Namespaced"
      "version" = "v1alpha1"
    }
  }
}


resource "kubernetes_manifest" "clustercollectors_crd" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1beta1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "name" = "clustercollectors.appdynamics.com"
    }
    "spec" = {
      "group" = "appdynamics.com"
      "names" = {
        "kind" = "Clustercollector"
        "listKind" = "ClustercollectorList"
        "plural" = "clustercollectors"
        "singular" = "clustercollector"
      }
      "scope" = "Namespaced"
      "validation" = {
        "openAPIV3Schema" = {
          "description" = "Clustercollector is the Schema for the clustercollectors API"
          "properties" = {
            "apiVersion" = {
              "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources"
              "type" = "string"
            }
            "kind" = {
              "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds"
              "type" = "string"
            }
            "metadata" = {
              "type" = "object"
            }
            "spec" = {
              "description" = "ClustercollectorSpec defines the desired state of Clustercollector"
              "properties" = {
                "image" = {
                  "type" = "string"
                }
                "serviceAccountName" = {
                  "type" = "string"
                }
              }
            }
          }
        }
      }
      "version" = "v1alpha1"
      "versions" = [
        {
          "name" = "v1alpha1"
          "served" = true
          "storage" = true
        },
      ]
    }
  }
}


resource "kubernetes_manifest" "infravizs_crd" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1beta1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "name" = "infravizs.appdynamics.com"
    }
    "spec" = {
      "group" = "appdynamics.com"
      "names" = {
        "kind" = "InfraViz"
        "listKind" = "InfraVizList"
        "plural" = "infravizs"
        "singular" = "infraviz"
      }
      "scope" = "Namespaced"
      "version" = "v1alpha1"
      "versions" = [
        {
          "name" = "v1alpha1"
          "served" = true
          "storage" = true
        },
      ]
    }
  }
}


resource "kubernetes_manifest" "adams_crd" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1beta1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "name" = "adams.appdynamics.com"
    }
    "spec" = {
      "group" = "appdynamics.com"
      "names" = {
        "kind" = "Adam"
        "listKind" = "AdamList"
        "plural" = "adams"
        "singular" = "adam"
      }
      "scope" = "Namespaced"
      "version" = "v1alpha1"
      "versions" = [
        {
          "name" = "v1alpha1"
          "served" = true
          "storage" = true
        },
      ]
    }
  }
}


resource "helm_release" "appd-crd" {
  name       = "appd-crd"
  
  depends_on = [kubernetes_manifest.clusteragents_crd, kubernetes_manifest.clustercollectors_crd, kubernetes_manifest.infravizs_crd, kubernetes_manifest.adams_crd]

  chart      = "${path.module}/helm/"

  namespace  = var.namespace

  set {
    name  = "appname"
    value = var.cluster_name
  }

  set {
    name  = "appd_account_name"
    value = var.appd_account_name
  }

  set {
    name  = "appd_controller_url"
    value = var.appd_controller_url
  }

  set {
    name  = "appd_global_account"
    value = var.appd_global_account
  }

  set {
    name  = "proxy_url"
    value = var.proxy_url
  }

  set {
    name  = "ns_to_monitor"
    value = "{${join(",", var.ns_to_monitor)}}"
  }

  set {
    name  = "ns_to_instrument"
    value = var.ns_to_instrument
  }
  
  set {
    name  = "instrumentation_app_name"
    value = var.instrumentation_app_name
  }

  set {
    name  = "registry"
    value = var.registry
  }
}

data "digitalocean_vpc" "vpc" {
  name = var.vpc
}

# data items for firewall rules
data "digitalocean_droplet" "tailscale_subnet_router" {
  name = var.vpn
}

data "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name = var.k8s
}

locals {
  cluster_name = coalesce(
    var.cluster_name,
      join("-", [
        "db-redis",
        data.digitalocean_vpc.vpc.region,
        var.instance,
        var.app
    ])
  )

  labels = {
    "app.kubernetes.io/component" = "cache"
    "app.kubernetes.io/instance" = var.instance
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/name" = "redis"
    "app.kubernetes.io/part-of" = var.app
    "app.kubernetes.io/version" = var.redis_version
  }

  size = "db-${coalesce(var.tier, "s")}-${var.cpus}vcpu-${var.memory_gb}gb"

  tags = compact(["db", var.instance, var.app])
}

resource "digitalocean_database_cluster" "redis_cluster" {
  engine               = "valkey"
  name                 = local.cluster_name
  node_count           = var.node_count
  private_network_uuid = data.digitalocean_vpc.vpc.id
  region               = data.digitalocean_vpc.vpc.region
  size                 = local.size
  tags                 = local.tags
  version              = var.redis_version
}

resource "digitalocean_database_firewall" "redis_firewall" {
  cluster_id = digitalocean_database_cluster.redis_cluster.id

  # Tailscale subnet router
  rule {
    type  = "droplet"
    value = data.digitalocean_droplet.tailscale_subnet_router.id
  }

  # Kubernetes cluster where Canvas runs
  rule {
    type = "k8s"
    value = data.digitalocean_kubernetes_cluster.k8s_cluster.id
  }
}

resource "kubernetes_secret" "k8s_secrets" {
  metadata {
    labels = local.labels
    name = "${var.app}-redis-secrets"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    "REDIS_URL" = digitalocean_database_cluster.redis_cluster.private_uri
  }
}

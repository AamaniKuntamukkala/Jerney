# ==============================================================
# Journey AKS Cluster - Modular Approach (with Terraform functions)
# ==============================================================

# ---- Locals ----
# Use cidrsubnet to carve multiple subnets from the VNet CIDR
locals {
  # Create 3 subnets from the base CIDR
  subnet_prefixes = [
    for i in range(3) : cidrsubnet(var.vpc_cidr, 8, i)
  ]

  subnet_names = [
    for i in range(3) : "subnet-${i}"
  ]

  # Define multiple node pools dynamically
  node_pools = [
    {
      name       = "system"
      node_count = var.node_count
      vm_size    = var.node_vm_size
    },
    {
      name       = "general-purpose"
      node_count = 2
      vm_size    = "Standard_DS3_v2"
    },
    {
      name       = "compute"
      node_count = 1
      vm_size    = "Standard_DS4_v2"
    }
  ]
}

# ---- VNet ----
module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.0.0"

  resource_group_name = "${var.cluster_name}-rg"
  vnet_name           = "${var.cluster_name}-vnet"
  address_space       = [var.vpc_cidr]

  subnet_prefixes = local.subnet_prefixes
  subnet_names    = local.subnet_names
}

# ---- AKS Cluster ----
module "aks" {
  source  = "Azure/aks/azurerm"
  version = "6.0.0"

  resource_group_name = module.vnet.resource_group_name
  cluster_name        = var.cluster_name
  location            = var.location

  # Networking
  subnet_ids = module.vnet.subnet_ids

  # Cluster version
  kubernetes_version = var.cluster_version

  # Default node pool
  default_node_pool = local.node_pools[0]

  # Additional node pools (slice to skip the first one)
  additional_node_pools = slice(local.node_pools, 1, length(local.node_pools))

  # RBAC and Identity
  role_based_access_control_enabled = true
  identity_type                     = "SystemAssigned"

  # Logging/monitoring
  enable_log_analytics_workspace = true
}

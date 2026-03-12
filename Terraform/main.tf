# ==============================================================
# Journey AKS Cluster - Modular Approach (corrected for Azure module)
# ==============================================================

locals {
  subnet_prefixes = [
    for i in range(3) : cidrsubnet(var.vpc_cidr, 8, i)
  ]

  subnet_names = [
    for i in range(3) : "subnet-${i}"
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

  prefix              = var.cluster_name
  resource_group_name = module.vnet.resource_group_name
  location            = var.location

  # Networking: only one subnet supported here
  vnet_subnet_id = module.vnet.subnet_ids[0]

  # Node pool sizing
  agents_size  = var.node_vm_size
  agents_count = var.node_count

  # Kubernetes version
  kubernetes_version = var.cluster_version

  # RBAC
  role_based_access_control_enabled = true
}

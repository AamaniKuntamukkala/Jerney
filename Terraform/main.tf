# ==============================================================
# Journey AKS Cluster - Direct Resources (with Terraform functions)
# ==============================================================

provider "azurerm" {
  features {}
}

# ---- Locals ----
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

# ---- Resource Group ----
resource "azurerm_resource_group" "rg" {
  name     = "${var.cluster_name}-rg"
  location = var.location
}

# ---- VNet ----
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.cluster_name}-vnet"
  address_space       = [var.vpc_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# ---- Subnets ----
resource "azurerm_subnet" "subnets" {
  for_each             = toset(local.subnet_names)
  name                 = each.value
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.subnet_prefixes[index(local.subnet_names, each.value)]]
}

# ---- Log Analytics Workspace ----
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.cluster_name}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---- AKS Cluster ----
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.cluster_name}-dns"

  default_node_pool {
    name           = local.node_pools[0].name
    node_count     = local.node_pools[0].node_count
    vm_size        = local.node_pools[0].vm_size
    vnet_subnet_id = values(azurerm_subnet.subnets)[0].id
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

  kubernetes_version = var.cluster_version
}

# ---- Additional Node Pools ----
resource "azurerm_kubernetes_cluster_node_pool" "extra_pools" {
  for_each              = { for np in slice(local.node_pools, 1, length(local.node_pools)) : np.name => np }
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  vnet_subnet_id        = values(azurerm_subnet.subnets)[0].id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "IDs of the subnets created"
  value       = [for s in azurerm_subnet.subnets : s.id]
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  description = "Kubeconfig for accessing the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

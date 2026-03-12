output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.vnet.resource_group_name
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = module.vnet.vnet_name
}

output "subnet_ids" {
  description = "IDs of the subnets created"
  value       = module.vnet.subnet_ids
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_kube_config" {
  description = "Kubeconfig for accessing the AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}

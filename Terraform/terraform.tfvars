# Cluster settings
cluster_name   = "journey-aks"
location       = "eastus"
cluster_version = "1.29.0"   # optional if you want to pin AKS version

# Networking
vpc_cidr       = "10.1.0.0/16"

# Node pool
node_count     = 3
node_vm_size   = "Standard_DS3_v2"

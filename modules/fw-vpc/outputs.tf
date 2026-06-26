output "vpc_instances" {
  description = "vpc firewall instance list"
  value       = local.vpc_instances
}

output "fw_group_id" {
  description = "Firewall group ID for policy configuration."
  value       = var.create_vpc_fw_instance ? tencentcloud_cfw_vpc_instance.instance[0].fw_group_id : null
}
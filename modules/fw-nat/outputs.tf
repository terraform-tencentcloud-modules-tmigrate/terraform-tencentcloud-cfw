output "nat_instance_id" {
  description = "ID of the resource."
  value       = var.create_cfw_nat_instance ? tencentcloud_cfw_nat_instance.instance[0].id : null
}
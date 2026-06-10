output "route_item_ids" {
  value = { for k, v in tencentcloud_route_table_entry.havip_route_entries : k => v.route_item_id }
}

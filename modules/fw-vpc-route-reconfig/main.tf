locals {
  has_vpc = var.vpc_id != null && var.vpc_id != ""
  route_next_type = "HAVIP"
  # get vpc default route table
  default_routetable = local.has_vpc ? [ for rt in data.tencentcloud_vpc_route_tables.route_tables.instance_list : rt ][0] : null
  # get ccn route entry infos
  ccn_route_entries = local.default_routetable != null ? [ for rei in local.default_routetable.route_entry_infos : rei if rei.next_type == "CCN" ] : []
  republish_route_entries = var.ccn_fw_type == "NAT" ? [ for rei in local.ccn_route_entries : rei if rei.destination_cidr_block == "0.0.0.0/0" ] : [ for rei in local.ccn_route_entries : rei if rei.destination_cidr_block != "0.0.0.0/0" ]
  # maps keyed by route_entry_id
  ccn_route_entries_map       = { for rei in local.ccn_route_entries : rei.route_entry_id => rei }
  republish_route_entries_map = { for rei in local.republish_route_entries : rei.route_entry_id => rei }
}

# get vpc route tables
data "tencentcloud_vpc_route_tables" "route_tables" {
  vpc_id           = var.vpc_id
  association_main = true
}

# enbaled or disable ccn route entries
resource "tencentcloud_route_table_entry_config" "entry_config" {
  for_each = local.ccn_route_entries_map

  route_table_id = local.default_routetable.route_table_id
  route_item_id  = each.value.route_item_id
  disabled       = true
}

# create new HAVIP route entry for ccn
resource "tencentcloud_route_table_entry" "havip_route_entries" {
  for_each = local.republish_route_entries_map

  route_table_id         = local.default_routetable.route_table_id
  next_type              = local.route_next_type
  next_hub               = var.gateway_id
  destination_cidr_block = each.value.destination_cidr_block
  description            = each.value.description

  depends_on = [ tencentcloud_route_table_entry_config.entry_config ]
}

# publish route entry to ccn
resource "tencentcloud_vpc_notify_routes" "publish_to_ccn" {
  for_each = local.republish_route_entries_map

  route_table_id = local.default_routetable.route_table_id
  route_item_ids = [tencentcloud_route_table_entry.havip_route_entries[each.key].route_item_id]

  depends_on = [tencentcloud_route_table_entry.havip_route_entries]
}

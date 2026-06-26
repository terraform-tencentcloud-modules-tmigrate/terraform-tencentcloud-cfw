locals {
  policy_uuid_list = [ for idx, policy in var.vpc_fw_policies : tencentcloud_cfw_vpc_policy.policies[idx].uuid ]

  vpc_instances = var.create_vpc_fw_instance ? [
    for item in tencentcloud_cfw_vpc_instance.instance[0].vpc_fw_instances : {
      instance_id   = item.fw_ins_id
      instance_name = item.name
      havip_infos = [
        for gw in item.fw_gateway : {
          gateway_id = gw.gateway_id
          vpc_id     = gw.vpc_id
          ip_address = gw.ip_address
        }
      ]
    }
  ] : []
}

resource "tencentcloud_cfw_vpc_instance" "instance" {
  count = var.create_vpc_fw_instance ? 1 : 0
  ccn_id      = var.ccn_id
  name        = var.name
  mode        = var.mode
  switch_mode = var.switch_mode
  fw_vpc_cidr = var.fw_vpc_cidr

  dynamic "vpc_fw_instances" {
    for_each = var.fw_instances
    content {
      name    = vpc_fw_instances.value.name
      vpc_ids = vpc_fw_instances.value.vpc_ids

      dynamic "fw_deploy" {
        for_each = vpc_fw_instances.value.fw_deploy
        content {
          deploy_region = fw_deploy.value.deploy_region
          width         = fw_deploy.value.width
          zone_set      = fw_deploy.value.zone_set
          cross_a_zone  = fw_deploy.value.cross_a_zone
        }
      }
    }
  }
  
  lifecycle {
    ignore_changes = [ fw_vpc_cidr ]
  }
}

resource "tencentcloud_cfw_vpc_policy" "policies" {
  for_each = { for idx, policy in var.vpc_fw_policies : idx => policy }

  fw_group_id = var.vpc_fw_group_id != null ? var.vpc_fw_group_id : tencentcloud_cfw_vpc_instance.instance[0].fw_group_id

  enable         = each.value.enable
  description    = each.value.description
  dest_content   = each.value.dest_content
  dest_type      = each.value.dest_type
  port           = each.value.port
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  source_content = each.value.source_content
  source_type    = each.value.source_type

  depends_on = [ tencentcloud_cfw_vpc_instance.instance ]
}

resource "tencentcloud_cfw_vpc_policy_order_config" "policies_order" {
  count = length(local.policy_uuid_list) > 0 ? 1 : 0
  rule_uuid_list = local.policy_uuid_list

  depends_on = [
    tencentcloud_cfw_vpc_policy.policies
  ]
}
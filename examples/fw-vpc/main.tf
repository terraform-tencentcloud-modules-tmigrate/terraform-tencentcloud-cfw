terraform {
  required_version = ">= 1.1.0"

  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = ">= 1.82.61"
    }
  }
}

# ─── mock 入参，先确认结构 ───

locals {
  ccn_id      = "ccn-jm1nu99d"
  name        = "lz-vpc-fw"
  mode        = 1 # 0: 私网模式; 1: CCN 云联网模式
  switch_mode = 4 # 1: 单点互通; 2: 多点互通; 4: 自定义路由
  fw_vpc_cidr = "172.31.16.0/20"

  fw_instances = [
    {
      name    = "lz-vpc-fw-instance"
      vpc_ids = []
      fw_deploy = [
        {
          deploy_region = "ap-singapore"
          width         = 100
          zone_set      = ["ap-singapore-2", "ap-singapore-4"]
          cross_a_zone  = 1 # 1: use off-site disaster recovery; 0: do not use off-site disaster recovery; if it is empty, off-site disaster recovery will not be used by default.
        }
      ]
    }
  ]

  vpc_fw_policies = [
    # {
    #   description    = "allow internal to internal tcp 443"
    #   source_type    = "net"
    #   source_content = "10.0.0.0/16"
    #   dest_type      = "net"
    #   dest_content   = "10.1.0.0/16"
    #   protocol       = "TCP"
    #   port           = "443"
    #   rule_action    = "accept"
    #   enable         = "true"
    # },
    # {
    #   description    = "drop all other"
    #   source_type    = "net"
    #   source_content = "0.0.0.0/0"
    #   dest_type      = "net"
    #   dest_content   = "0.0.0.0/0"
    #   protocol       = "ANY"
    #   port           = "-1/-1"
    #   rule_action    = "drop"
    #   enable         = "true"
    # }
  ]
}

module "fw_vpc" {
  source = "../../modules/fw-vpc"
  providers = {
    tencentcloud = tencentcloud.network
  }

  ccn_id      = local.ccn_id
  name        = local.name
  mode        = local.mode
  switch_mode = local.switch_mode
  fw_vpc_cidr = local.fw_vpc_cidr

  fw_instances    = local.fw_instances
  vpc_fw_policies = local.vpc_fw_policies
}

output "vpc_instances" {
  value = module.fw_vpc.vpc_instances
}

output "fw_group_id" {
  value = module.fw_vpc.fw_group_id
}

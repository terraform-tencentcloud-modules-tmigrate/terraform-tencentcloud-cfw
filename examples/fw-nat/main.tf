terraform {
  required_version = ">= 1.1.0"

  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = ">= 1.82.61"
    }
  }
}

# ─── 入参，等待填写 ───

locals {


  # 集群 NAT 防火墙 CCN 开关（可选，不填则不创建）
  cluster_nat_fw_switches = [
    {
      nat_ins_id   = "nat-95xxxx"
      ccn_id       = "ccn-jmxxxxx"
      switch_mode  = 1
      routing_mode = 1
      access_instance_list = [
        {
          instance_id      = "vpc-rwxxxxx"
          instance_type    = "VPC"
          instance_region  = "ap-singapore"
          access_cidr_mode = 1
          access_cidr_list = ["172.31.6.0/25"]
        },
        {
          instance_id      = "vpc-rwxxxxx"
          instance_type    = "VPC"
          instance_region  = "ap-singapore"
          access_cidr_mode = 1
          access_cidr_list = ["172.31.7.0/25"]
        }
      ]
    }
  ]
}

module "fw_nat" {
  source = "../../modules/fw-nat"

  cluster_nat_fw_switches = local.cluster_nat_fw_switches

  # 只创建 instance，不创建防火墙开关和策略
  switches          = []
  inbound_policies  = []
  outbound_policies = []
}

output "nat_instance_id" {
  value = module.fw_nat.nat_instance_id
}

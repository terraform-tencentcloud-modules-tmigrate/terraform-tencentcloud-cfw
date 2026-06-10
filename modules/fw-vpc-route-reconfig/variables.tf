variable "vpc_id" {
  description = "(Required, String) VPC ID of VPC firewall."
  type        = string
}

variable "gateway_id" {
  description = "(Required, String) Gateway ID of VPC firewall."
  type        = string
}

variable "ccn_fw_type" {
  description = "(Optional, String) CCN firewall type. VPC: republish non-default routes; NAT: republish default route only. Valid values: VPC, NAT."
  type        = string
  default     = "VPC"
  validation {
    condition     = contains(["VPC", "NAT"], var.ccn_fw_type)
    error_message = "ccn_fw_type must be 'VPC' or 'NAT'."
  }
}
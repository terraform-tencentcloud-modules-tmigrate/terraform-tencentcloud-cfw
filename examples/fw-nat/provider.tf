provider "tencentcloud" {
  alias  = "network"
  region = "ap-singapore"

  assume_role {
    role_arn         = "qcs::cam::uin/200049495346:roleName/dap-AutomateAdminRole"
    session_name     = "tf-network"
    session_duration = 3600
  }
}

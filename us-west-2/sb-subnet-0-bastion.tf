###################################################################################################
# Create Sitebridge Bastion Inside Subnet-0
##################################################################################################
locals {
  subnet0Prefix = "${var.vpcName}-${var.subnet0Name}"
}

########################################################################
# 1. Create Sitebridge Cluster Name: sitebridge-prod-aws-usw-2-vpc-1-subnet-0-bastion-1
########################################################################
variable "bastionName" {
  default = "bastion"
}

variable "bastionNumInstances" {
  default = "1"
}

variable "bastionAmiList" {
  type = "list"

  default = [
    "ami-a042f4d8",
  ]
}

variable "bastionInstanceTypeList" {
  type    = "list"
  default = ["t2.micro"]
}

variable bastionExternalIPs {
  type    = "list"
  default = []
}

variable "bastionNamePrefix" {
  default = "ops0-bastion1"
}

variable "bastionNameSuffix" {
  default = "usw2-eng.awssb.sfdcsb.net"
}

module "aws_usw2_sb_bastion1" {
  source = "../bastion"

  numInstances        = "${var.bastionNumInstances}"
  name                = "${local.subnet0Prefix}-${var.bastionName}"
  amiList             = "${var.bastionAmiList}"
  instanceTypeList    = "${var.bastionInstanceTypeList}"
  externalIPs         = "${var.bastionExternalIPs}"
  instanceNamePrefix  = "${var.bastionNamePrefix}"
  instanceNameSuffix  = "${var.bastionNameSuffix}"
  subnetId            = "${module.subnet-0.subnetID}"
  vpcSecurityGroupIds = ["${aws_security_group.subnet-0-bastion-sg.id}"]
}

########################################################################
# Output Definitions
########################################################################
output "aws_usw2_sb_bastion1_output" {
  value = "${module.aws_usw2_sb_bastion1.hosts_info}"
}

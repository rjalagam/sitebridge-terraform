############################################################################################################################################
# Create Sitebridge Clusters Inside Subnet-1
##################################################################################################
locals {
  instanceNamePrefix = "instanceNamePrefix"
  instanceNameSuffix = "instanceNameSuffix"
  instanceType       = "instanceType"
  kingdom            = "kingdom"
  numInstances       = "numInstances"
  resourceName       = "resourceName"
  sitebridge         = "sitebridge"
  sitebridgeImage    = "sitebridgeImage"
}

############################################################################################################################################
# 1. Create Sitebridge Cluster: aws_usw2_sb_cnitest
#    local  sitebridge     : aws-usw2-sb-cnitest
#    remote sitebridge     : xrd2
#    local  kingdom        : aws-usw2-cust-cnitest
#    remote kingdom        : xrd2
#    instance name pattern : ops0-cnitest1-1-usw2-eng.awssb.sfdcsb.net
########################################################################
variable "aws_usw2_sb_cnitest1_input" {
  type = "map"

  default = {
    "instanceNamePrefix" = "ops0-cnitest1"
    "instanceNameSuffix" = "usw2-eng.awssb.sfdcsb.net"
    "kingdom"            = "aws-usw2-cust-cnitest"
    "numInstances"       = "1"
    "resourceName"       = "aws-usw2-sb-cnitest1"
    "remoteSitebridge"   = "prd1"
    "remoteKingdom"      = "prd1"
    "sitebridge"         = "aws-usw2-sb-cnitest"
    "sitebridgeImage"    = "099350349688.dkr.ecr.us-west-2.amazonaws.com/sitebridge:cloud-latest"
  }
}

variable "aws_usw2_sb_cnitest1_ami_list" {
  type = "list"

  default = []
}

variable "aws_usw2_sb_cnitest1_instance_type_list" {
  type = "list"

  default = [
    "c5.4xlarge",
  ]
}

variable "aws_usw2_sb_cnitest1_cloud_init_folder" {
  type = "list"

  default = [
    "current",
  ]
}

module "aws_usw2_sb_cnitest1" {
  source = "../cluster"

  region             = "${var.region}"
  instanceTypeList   = "${var.aws_usw2_sb_cnitest1_instance_type_list}"
  amiList            = "${var.aws_usw2_sb_cnitest1_ami_list}"
  instanceNamePrefix = "${var.aws_usw2_sb_cnitest1_input[local.instanceNamePrefix]}"
  instanceNameSuffix = "${var.aws_usw2_sb_cnitest1_input[local.instanceNameSuffix]}"
  kingdom            = "${var.aws_usw2_sb_cnitest1_input[local.sitebridge]}"
  numInstances       = "${var.aws_usw2_sb_cnitest1_input[local.numInstances]}"
  resourceName       = "${var.aws_usw2_sb_cnitest1_input[local.resourceName]}"
  sitebridge         = "${var.aws_usw2_sb_cnitest1_input[local.sitebridge]}"
  sitebridgeImage    = "${var.aws_usw2_sb_cnitest1_input[local.sitebridgeImage]}"
  cloudInitFolder    = "${var.aws_usw2_sb_cnitest1_cloud_init_folder}"

  platformName           = "${var.platformName}"
  subnet_id              = "${module.subnet-1.subnetID}"
  vpc_id                 = "${aws_vpc.sitebridge-vpc.id}"
  igw_id                 = "${aws_internet_gateway.sitebridge-vpc-internet-gateway.id}"
  natpool_cidr_block     = "${var.vpcNatPoolCidrBlock}"
  vpc_security_group_ids = ["${aws_security_group.subnet-1-security-group.id}"]
}

output "aws_usw2_sb_cnitest1_output_hosts" {
  value = "${module.aws_usw2_sb_cnitest1.sb_hosts_info}"
}

module "aws_usw2_sb_cnitest1_s3" {
  source       = "../output"
  region       = "${var.region}"
  cluster_info = "${var.aws_usw2_sb_cnitest1_input}"
  hosts_info   = "${module.aws_usw2_sb_cnitest1.sb_hosts_info}"
}

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

// This should have the same number of static external ip name as there are number of instances in the cluster
variable "aws_usw2_sb_cnitest1_external_ips" {
  type = "list"

  default = [
    "34.222.66.211",
  ]
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

  instanceTypeList   = "${var.aws_usw2_sb_cnitest1_instance_type_list}"
  amiList            = "${var.aws_usw2_sb_cnitest1_ami_list}"
  instanceNamePrefix = "${var.aws_usw2_sb_cnitest1_input[local.instanceNamePrefix]}"
  instanceNameSuffix = "${var.aws_usw2_sb_cnitest1_input[local.instanceNameSuffix]}"
  kingdom            = "${var.aws_usw2_sb_cnitest1_input[local.sitebridge]}"
  numInstances       = "${var.aws_usw2_sb_cnitest1_input[local.numInstances]}"
  resourceName       = "${var.aws_usw2_sb_cnitest1_input[local.resourceName]}"
  sitebridge         = "${var.aws_usw2_sb_cnitest1_input[local.sitebridge]}"
  sitebridgeImage    = "${var.aws_usw2_sb_cnitest1_input[local.sitebridgeImage]}"
  externalIPs        = "${var.aws_usw2_sb_cnitest1_external_ips}"
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

############################################################################################################################################
# 2. Create Sitebridge Cluster: aws_usw2_sb_bravo1
#    local  sitebridge     : aws-usw2-sb-bravo
#    remote sitebridge     : xrd2
#    local  kingdom        : aws-usw2-cust-bravo
#    remote kingdom        : xrd2
#    instance name pattern : ops0-bravo1-1-usw2.awssb.sfdcsb.net
########################################################################
variable "aws_usw2_sb_bravo1_input" {
  type = "map"

  default = {
    "instanceNamePrefix" = "ops0-bravo1"
    "instanceNameSuffix" = "usw2-eng.awssb.sfdcsb.net"
    "kingdom"            = "aws-usw2-cust-bravo"
    "numInstances"       = "1"
    "resourceName"       = "aws-usw2-sb-bravo1"
    "remoteSitebridge"   = "prd1"
    "remoteKingdom"      = "prd1"
    "sitebridge"         = "aws-usw2-sb-bravo"
    "sitebridgeImage"    = "099350349688.dkr.ecr.us-west-2.amazonaws.com/sitebridge:cloud-latest"
  }
}

// This should have the same number of static external ip name as there are number of instances in the cluster
variable "aws_usw2_sb_bravo1_external_ips" {
  type = "list"

  default = [
    "34.222.66.212",
  ]
}

variable "aws_usw2_sb_bravo1_ami_list" {
  type = "list"

  default = []
}

variable "aws_usw2_sb_bravo1_instance_type_list" {
  type = "list"

  default = [
    "c5.4xlarge",
  ]
}

variable "aws_usw2_sb_bravo1_cloud_init_folder" {
  type = "list"

  default = [
    "current",
  ]
}

module "aws_usw2_sb_bravo1" {
  source = "../cluster"

  instanceTypeList   = "${var.aws_usw2_sb_bravo1_instance_type_list}"
  amiList            = "${var.aws_usw2_sb_bravo1_ami_list}"
  instanceNamePrefix = "${var.aws_usw2_sb_bravo1_input[local.instanceNamePrefix]}"
  instanceNameSuffix = "${var.aws_usw2_sb_bravo1_input[local.instanceNameSuffix]}"
  kingdom            = "${var.aws_usw2_sb_bravo1_input[local.sitebridge]}"
  numInstances       = "${var.aws_usw2_sb_bravo1_input[local.numInstances]}"
  resourceName       = "${var.aws_usw2_sb_bravo1_input[local.resourceName]}"
  sitebridge         = "${var.aws_usw2_sb_bravo1_input[local.sitebridge]}"
  sitebridgeImage    = "${var.aws_usw2_sb_bravo1_input[local.sitebridgeImage]}"
  externalIPs        = "${var.aws_usw2_sb_bravo1_external_ips}"
  cloudInitFolder    = "${var.aws_usw2_sb_bravo1_cloud_init_folder}"

  platformName           = "${var.platformName}"
  subnet_id              = "${module.subnet-1.subnetID}"
  vpc_id                 = "${aws_vpc.sitebridge-vpc.id}"
  igw_id                 = "${aws_internet_gateway.sitebridge-vpc-internet-gateway.id}"
  natpool_cidr_block     = "${var.vpcNatPoolCidrBlock}"
  vpc_security_group_ids = ["${aws_security_group.subnet-1-security-group.id}"]
}

output "aws_usw2_sb_bravo1_output" {
  value = "${module.aws_usw2_sb_bravo1.sb_hosts_info}"
}

module "aws_usw2_sb_bravo1_s3" {
  source       = "../output"
  region       = "${var.region}"
  cluster_info = "${var.aws_usw2_sb_bravo1_input}"
  hosts_info   = "${module.aws_usw2_sb_bravo1.sb_hosts_info}"
}

############################################################################################################################################
# 3. Create Sitebridge Cluster: aws_usw2_sb_charlie
#    local  sitebridge     : aws-usw2-cust-charlie
#    remote sitebridge     : xrd2
#    local  kingdom        : aws-usw2-cust-charlie
#    remote kingdom        : xrd2
#    instance name pattern : ops0-charlie1-1-usw2.awssb.sfdcsb.net
########################################################################
variable "aws_usw2_sb_charlie1_input" {
  type = "map"

  default = {
    "instanceNamePrefix" = "ops0-charlie1"
    "instanceNameSuffix" = "usw2-eng.awssb.sfdcsb.net"
    "kingdom"            = "aws-usw2-cust-charlie"
    "numInstances"       = "1"
    "resourceName"       = "aws-usw2-sb-charlie1"
    "remoteSitebridge"   = "prd1"
    "remoteKingdom"      = "prd1"
    "sitebridge"         = "aws-usw2-sb-charlie"
    "sitebridgeImage"    = "099350349688.dkr.ecr.us-west-2.amazonaws.com/sitebridge:cloud-latest"
  }
}

// This should have the same number of static external ip name as there are number of instances in the cluster
variable "aws_usw2_sb_charlie1_external_ips" {
  type = "list"

  default = []
}

variable "aws_usw2_sb_charlie1_ami_list" {
  type = "list"

  default = [
    "ami-02f059d9e8bb5d532",
  ]
}

variable "aws_usw2_sb_charlie1_instance_type_list" {
  type = "list"

  default = []
}

variable "aws_usw2_sb_charlie1_cloud_init_folder" {
  type = "list"

  default = [
    "charlie",
  ]
}

module "aws_usw2_sb_charlie1" {
  source = "../cluster"

  instanceTypeList   = "${var.aws_usw2_sb_charlie1_instance_type_list}"
  amiList            = "${var.aws_usw2_sb_charlie1_ami_list}"
  instanceNamePrefix = "${var.aws_usw2_sb_charlie1_input[local.instanceNamePrefix]}"
  instanceNameSuffix = "${var.aws_usw2_sb_charlie1_input[local.instanceNameSuffix]}"
  kingdom            = "${var.aws_usw2_sb_charlie1_input[local.sitebridge]}"
  numInstances       = "${var.aws_usw2_sb_charlie1_input[local.numInstances]}"
  resourceName       = "${var.aws_usw2_sb_charlie1_input[local.resourceName]}"
  sitebridge         = "${var.aws_usw2_sb_charlie1_input[local.sitebridge]}"
  sitebridgeImage    = "${var.aws_usw2_sb_charlie1_input[local.sitebridgeImage]}"
  externalIPs        = "${var.aws_usw2_sb_charlie1_external_ips}"
  cloudInitFolder    = "${var.aws_usw2_sb_charlie1_cloud_init_folder}"

  platformName           = "${var.platformName}"
  subnet_id              = "${module.subnet-1.subnetID}"
  vpc_id                 = "${aws_vpc.sitebridge-vpc.id}"
  igw_id                 = "${aws_internet_gateway.sitebridge-vpc-internet-gateway.id}"
  natpool_cidr_block     = "${var.vpcNatPoolCidrBlock}"
  vpc_security_group_ids = ["${aws_security_group.subnet-1-security-group.id}"]
}

output "aws_usw2_sb_charlie1_output" {
  value = "${module.aws_usw2_sb_charlie1.sb_hosts_info}"
}

module "aws_usw2_sb_charlie1_s3" {
  source       = "../output"
  region       = "${var.region}"
  cluster_info = "${var.aws_usw2_sb_charlie1_input}"
  hosts_info   = "${module.aws_usw2_sb_charlie1.sb_hosts_info}"
}

############################################################################################################################################
# 4. Create Sitebridge Cluster: aws_usw2_sb_delta
#    local  sitebridge     : aws-usw2-cust-delta
#    remote sitebridge     : xrd2
#    local  kingdom        : aws-usw2-cust-delta
#    remote kingdom        : xrd2
#    instance name pattern : ops0-delta1-1-usw2.awssb.sfdcsb.net
########################################################################
variable "aws_usw2_sb_delta1_input" {
  type = "map"

  default = {
    "instanceNamePrefix" = "ops0-delta1"
    "instanceNameSuffix" = "usw2-eng.awssb.sfdcsb.net"
    "kingdom"            = "aws-usw2-cust-delta"
    "numInstances"       = "1"
    "resourceName"       = "aws-usw2-sb-delta1"
    "remoteSitebridge"   = "prd1"
    "remoteKingdom"      = "prd1"
    "sitebridge"         = "aws-usw2-sb-delta"
    "sitebridgeImage"    = "099350349688.dkr.ecr.us-west-2.amazonaws.com/sitebridge:cloud-latest"
  }
}

// This should have the same number of static external ip name as there are number of instances in the cluster
variable "aws_usw2_sb_delta1_external_ips" {
  type = "list"

  default = []
}

variable "aws_usw2_sb_delta1_ami_list" {
  type = "list"

  default = []
}

variable "aws_usw2_sb_delta1_instance_type_list" {
  type = "list"

  default = [
    "c5.4xlarge",
  ]
}

variable "aws_usw2_sb_delta1_cloud_init_folder" {
  type = "list"

  default = [
    "current",
  ]
}

module "aws_usw2_sb_delta1" {
  source = "../cluster"

  instanceTypeList   = "${var.aws_usw2_sb_delta1_instance_type_list}"
  amiList            = "${var.aws_usw2_sb_delta1_ami_list}"
  instanceNamePrefix = "${var.aws_usw2_sb_delta1_input[local.instanceNamePrefix]}"
  instanceNameSuffix = "${var.aws_usw2_sb_delta1_input[local.instanceNameSuffix]}"
  kingdom            = "${var.aws_usw2_sb_delta1_input[local.sitebridge]}"
  numInstances       = "${var.aws_usw2_sb_delta1_input[local.numInstances]}"
  resourceName       = "${var.aws_usw2_sb_delta1_input[local.resourceName]}"
  sitebridgeImage    = "${var.aws_usw2_sb_delta1_input[local.sitebridgeImage]}"
  sitebridge         = "${var.aws_usw2_sb_delta1_input[local.sitebridge]}"
  externalIPs        = "${var.aws_usw2_sb_delta1_external_ips}"
  cloudInitFolder    = "${var.aws_usw2_sb_delta1_cloud_init_folder}"

  platformName           = "${var.platformName}"
  subnet_id              = "${module.subnet-1.subnetID}"
  vpc_id                 = "${aws_vpc.sitebridge-vpc.id}"
  igw_id                 = "${aws_internet_gateway.sitebridge-vpc-internet-gateway.id}"
  natpool_cidr_block     = "${var.vpcNatPoolCidrBlock}"
  vpc_security_group_ids = ["${aws_security_group.subnet-1-security-group.id}"]
}

output "aws_usw2_sb_delta1_output" {
  value = "${module.aws_usw2_sb_delta1.sb_hosts_info}"
}

module "aws_usw2_sb_delta1_s3" {
  source       = "../output"
  region       = "${var.region}"
  cluster_info = "${var.aws_usw2_sb_delta1_input}"
  hosts_info   = "${module.aws_usw2_sb_delta1.sb_hosts_info}"
}

############################################################################################################################################
# 5. Create Sitebridge Cluster: aws_usw2_sb_echo
#    local  sitebridge     : aws-usw2-sb-echo
#    remote sitebridge     : aws
#    local  kingdom        : aws-usw2-sb-echo
#    remote kingdom        : aws
########################################################################
variable "aws_usw2_sb_echo1_input" {
  type = "map"

  default = {
    "instanceNamePrefix" = "ops0-echo1"
    "instanceNameSuffix" = "usw2-eng.awssb.sfdcsb.net"
    "kingdom"            = "aws-usw2-cust-echo"
    "numInstances"       = "4"
    "resourceName"       = "aws-usw2-sb-echo1"
    "remoteSitebridge"   = "aws"
    "remoteKingdom"      = "aws"
    "sitebridge"         = "aws-usw2-sb-echo"
    "sitebridgeImage"    = "099350349688.dkr.ecr.us-west-2.amazonaws.com/sitebridge:cloud-latest"
  }
}

// This should have the same number of static external ip name as there are number of instances in the cluster
variable "aws_usw2_sb_echo1_external_ips" {
  type = "list"

  default = [
    "34.222.66.253",
    "34.222.66.254",
    "34.222.66.255",
    "34.222.66.249",
  ]
}

variable "aws_usw2_sb_echo1_ami_list" {
  type = "list"

  default = [
    "ami-08e02b9cc3c192390",
    "ami-08e02b9cc3c192390",
    "ami-08e02b9cc3c192390",
    "ami-08e02b9cc3c192390",
  ]
}

variable "aws_usw2_sb_echo1_instance_type_list" {
  type = "list"

  default = [
    "c5.4xlarge",
    "c5.4xlarge",
    "c5.4xlarge",
    "c5.4xlarge",
  ]
}

variable "aws_usw2_sb_echo1_cloud_init_folder" {
  type = "list"

  default = [
    "current",
    "current",
    "current",
    "current",
  ]
}

module "aws_usw2_sb_echo1" {
  source = "../cluster"

  instanceTypeList   = "${var.aws_usw2_sb_echo1_instance_type_list}"
  amiList            = "${var.aws_usw2_sb_echo1_ami_list}"
  instanceNamePrefix = "${var.aws_usw2_sb_echo1_input[local.instanceNamePrefix]}"
  instanceNameSuffix = "${var.aws_usw2_sb_echo1_input[local.instanceNameSuffix]}"
  kingdom            = "${var.aws_usw2_sb_echo1_input[local.sitebridge]}"
  numInstances       = "${var.aws_usw2_sb_echo1_input[local.numInstances]}"
  resourceName       = "${var.aws_usw2_sb_echo1_input[local.resourceName]}"
  sitebridge         = "${var.aws_usw2_sb_echo1_input[local.sitebridge]}"
  sitebridgeImage    = "${var.aws_usw2_sb_echo1_input[local.sitebridgeImage]}"
  externalIPs        = "${var.aws_usw2_sb_echo1_external_ips}"
  cloudInitFolder    = "${var.aws_usw2_sb_echo1_cloud_init_folder}"

  platformName           = "${var.platformName}"
  subnet_id              = "${module.subnet-1.subnetID}"
  vpc_id                 = "${aws_vpc.sitebridge-vpc.id}"
  igw_id                 = "${aws_internet_gateway.sitebridge-vpc-internet-gateway.id}"
  natpool_cidr_block     = "${var.vpcNatPoolCidrBlock}"
  vpc_security_group_ids = ["${aws_security_group.subnet-1-security-group.id}"]
}

output "aws_usw2_sb_echo1_output" {
  value = "${module.aws_usw2_sb_echo1.sb_hosts_info}"
}

module "aws_usw2_sb_echo1_s3" {
  source       = "../output"
  region       = "${var.region}"
  cluster_info = "${var.aws_usw2_sb_echo1_input}"
  hosts_info   = "${module.aws_usw2_sb_echo1.sb_hosts_info}"
}

############################################################################################################################################
# 6. Create Sitebridge Cluster: aws_usw2_sb_sanity
#    local  sitebridge     : aws-usw2-sb-sanity
#    remote sitebridge     : xrd1
#    local  kingdom        : aws-usw2-sb-sanity
#    remote kingdom        : xrd1
########################################################################
variable "aws_usw2_sb_sanity_input" {
  type = "map"

  default = {
    "instanceNamePrefix" = "ops0-sanity1"
    "instanceNameSuffix" = "usw2-eng.awssb.sfdcsb.net"
    "kingdom"            = "aws-usw2-dev-sanity"
    "numInstances"       = "3"
    "resourceName"       = "aws-usw2-dev-sanity"
    "remoteSitebridge"   = "aws"
    "remoteKingdom"      = "aws"
    "sitebridge"         = "aws-usw2-sb-sanity"
    "sitebridgeImage"    = "099350349688.dkr.ecr.us-west-2.amazonaws.com/sitebridge:cloud-latest"
  }
}

// This should have the same number of static external ip name as there are number of instances in the cluster
variable "aws_usw2_sb_sanity_external_ips" {
  type = "list"

  default = [
    "34.222.66.250",
    "34.222.66.251",
    "34.222.66.252",
  ]
}

variable "aws_usw2_sb_sanity_ami_list" {
  type = "list"

  default = [
    "ami-08e02b9cc3c192390",
    "ami-08e02b9cc3c192390",
    "ami-08e02b9cc3c192390",
  ]
}

variable "aws_usw2_sb_sanity_instance_type_list" {
  type = "list"

  default = [
    "c5.4xlarge",
    "c5.4xlarge",
    "c5.4xlarge",
  ]
}

variable "aws_usw2_sb_sanity_cloud_init_folder" {
  type = "list"

  default = [
    "current",
    "current",
    "current",
  ]
}

module "aws_usw2_sb_sanity" {
  source = "../cluster"

  instanceTypeList   = "${var.aws_usw2_sb_sanity_instance_type_list}"
  amiList            = "${var.aws_usw2_sb_sanity_ami_list}"
  instanceNamePrefix = "${var.aws_usw2_sb_sanity_input[local.instanceNamePrefix]}"
  instanceNameSuffix = "${var.aws_usw2_sb_sanity_input[local.instanceNameSuffix]}"
  kingdom            = "${var.aws_usw2_sb_sanity_input[local.sitebridge]}"
  numInstances       = "${var.aws_usw2_sb_sanity_input[local.numInstances]}"
  resourceName       = "${var.aws_usw2_sb_sanity_input[local.resourceName]}"
  sitebridge         = "${var.aws_usw2_sb_sanity_input[local.sitebridge]}"
  sitebridgeImage    = "${var.aws_usw2_sb_sanity_input[local.sitebridgeImage]}"
  externalIPs        = "${var.aws_usw2_sb_sanity_external_ips}"
  instance_type      = "c5.4xlarge"
  cloudInitFolder    = "${var.aws_usw2_sb_sanity_cloud_init_folder}"

  platformName           = "${var.platformName}"
  subnet_id              = "${module.subnet-1.subnetID}"
  vpc_id                 = "${aws_vpc.sitebridge-vpc.id}"
  igw_id                 = "${aws_internet_gateway.sitebridge-vpc-internet-gateway.id}"
  natpool_cidr_block     = "${var.vpcNatPoolCidrBlock}"
  vpc_security_group_ids = ["${aws_security_group.subnet-1-security-group.id}"]
}

output "aws_usw2_sb_sanity_output" {
  value = "${module.aws_usw2_sb_sanity.sb_hosts_info}"
}

module "aws_usw2_sb_sanity_s3" {
  source       = "../output"
  region       = "${var.region}"
  cluster_info = "${var.aws_usw2_sb_sanity_input}"
  hosts_info   = "${module.aws_usw2_sb_sanity.sb_hosts_info}"
}

############################################################################################################################################
# 7. Create Sitebridge Cluster: aws_usw2_sb_foxtrot
#    local  sitebridge     : aws-usw2-sb-foxtrot
#    remote sitebridge     : xrd1
#    local  kingdom        : aws-usw2-sb-foxtrot
#    remote kingdom        : xrd1
########################################################################
variable "aws_usw2_sb_foxtrot_input" {
  type = "map"

  default = {
    "instanceNamePrefix" = "ops0-foxtrot1"
    "instanceNameSuffix" = "usw2-eng.awssb.sfdcsb.net"
    "kingdom"            = "aws-usw2-dev-foxtrot"
    "numInstances"       = "3"
    "resourceName"       = "aws-usw2-dev-foxtrot"
    "remoteSitebridge"   = "aws"
    "remoteKingdom"      = "aws"
    "sitebridge"         = "aws-usw2-sb-foxtrot"
    "sitebridgeImage"    = "099350349688.dkr.ecr.us-west-2.amazonaws.com/sitebridge:cloud-latest"
  }
}

// This should have the same number of static external ip name as there are number of instances in the cluster
variable "aws_usw2_sb_foxtrot_external_ips" {
  type = "list"

  default = [
    "34.222.66.198",
    "34.222.66.199",
    "34.222.66.200",
  ]
}

variable "aws_usw2_sb_foxtrot_ami_list" {
  type = "list"

  default = [
    "ami-08e02b9cc3c192390",
    "ami-08e02b9cc3c192390",
    "ami-08e02b9cc3c192390",
  ]
}

variable "aws_usw2_sb_foxtrot_instance_type_list" {
  type = "list"

  default = [
    "c5.4xlarge",
    "c5.4xlarge",
    "c5.4xlarge",
  ]
}

variable "aws_usw2_sb_foxtrot_cloud_init_folder" {
  type = "list"

  default = [
    "current",
    "current",
    "current",
  ]
}

module "aws_usw2_sb_foxtrot" {
  source = "../cluster"

  instanceTypeList   = "${var.aws_usw2_sb_foxtrot_instance_type_list}"
  amiList            = "${var.aws_usw2_sb_foxtrot_ami_list}"
  instanceNamePrefix = "${var.aws_usw2_sb_foxtrot_input[local.instanceNamePrefix]}"
  instanceNameSuffix = "${var.aws_usw2_sb_foxtrot_input[local.instanceNameSuffix]}"
  kingdom            = "${var.aws_usw2_sb_foxtrot_input[local.sitebridge]}"
  numInstances       = "${var.aws_usw2_sb_foxtrot_input[local.numInstances]}"
  resourceName       = "${var.aws_usw2_sb_foxtrot_input[local.resourceName]}"
  sitebridge         = "${var.aws_usw2_sb_foxtrot_input[local.sitebridge]}"
  sitebridgeImage    = "${var.aws_usw2_sb_foxtrot_input[local.sitebridgeImage]}"
  externalIPs        = "${var.aws_usw2_sb_foxtrot_external_ips}"
  cloudInitFolder    = "${var.aws_usw2_sb_foxtrot_cloud_init_folder}"

  platformName           = "${var.platformName}"
  subnet_id              = "${module.subnet-1.subnetID}"
  vpc_id                 = "${aws_vpc.sitebridge-vpc.id}"
  igw_id                 = "${aws_internet_gateway.sitebridge-vpc-internet-gateway.id}"
  natpool_cidr_block     = "${var.vpcNatPoolCidrBlock}"
  vpc_security_group_ids = ["${aws_security_group.subnet-1-security-group.id}"]
}

output "aws_usw2_sb_foxtrot_output" {
  value = "${module.aws_usw2_sb_foxtrot.sb_hosts_info}"
}

module "aws_usw2_sb_foxtrot_s3" {
  source       = "../output"
  region       = "${var.region}"
  cluster_info = "${var.aws_usw2_sb_foxtrot_input}"
  hosts_info   = "${module.aws_usw2_sb_foxtrot.sb_hosts_info}"
}

############################################################################################################################################
# 8. Create Sitebridge Cluster: aws_usw2_sb_testcontroller
#    local  sitebridge     : aws-usw2-sb-testcontroller
#    remote sitebridge     : xrd1
#    local  kingdom        : aws-usw2-sb-testcontroller
#    remote kingdom        : xrd1
########################################################################
variable "aws_usw2_sb_testcontroller_input" {
  type = "map"

  default = {
    "instanceNamePrefix" = "ops0-testcontroller1"
    "instanceNameSuffix" = "usw2-eng.awssb.sfdcsb.net"
    "kingdom"            = "aws-usw2-dev-testcontroller"
    "numInstances"       = "1"
    "resourceName"       = "aws-usw2-dev-testcontroller"
    "remoteSitebridge"   = "aws"
    "remoteKingdom"      = "aws"
    "sitebridge"         = "aws-usw2-sb-testcontroller"
    "sitebridgeImage"    = "099350349688.dkr.ecr.us-west-2.amazonaws.com/sitebridge:cloud-latest"
  }
}

// This should have the same number of static external ip name as there are number of instances in the cluster
variable "aws_usw2_sb_testcontroller_external_ips" {
  type = "list"

  default = [
    "34.222.66.220",
  ]
}

variable "aws_usw2_sb_testcontroller_ami_list" {
  type = "list"

  default = []
}

variable "aws_usw2_sb_testcontroller_instance_type_list" {
  type = "list"

  default = [
    "c5.4xlarge",
  ]
}

variable "aws_usw2_sb_testcontroller_cloud_init_folder" {
  type = "list"

  default = [
    "current",
  ]
}

module "aws_usw2_sb_testcontroller" {
  source = "../cluster"

  instanceTypeList   = "${var.aws_usw2_sb_testcontroller_instance_type_list}"
  amiList            = "${var.aws_usw2_sb_testcontroller_ami_list}"
  instanceNamePrefix = "${var.aws_usw2_sb_testcontroller_input[local.instanceNamePrefix]}"
  instanceNameSuffix = "${var.aws_usw2_sb_testcontroller_input[local.instanceNameSuffix]}"
  kingdom            = "${var.aws_usw2_sb_testcontroller_input[local.sitebridge]}"
  numInstances       = "${var.aws_usw2_sb_testcontroller_input[local.numInstances]}"
  resourceName       = "${var.aws_usw2_sb_testcontroller_input[local.resourceName]}"
  sitebridge         = "${var.aws_usw2_sb_testcontroller_input[local.sitebridge]}"
  sitebridgeImage    = "${var.aws_usw2_sb_testcontroller_input[local.sitebridgeImage]}"
  externalIPs        = "${var.aws_usw2_sb_testcontroller_external_ips}"
  cloudInitFolder    = "${var.aws_usw2_sb_testcontroller_cloud_init_folder}"

  platformName           = "${var.platformName}"
  subnet_id              = "${module.subnet-1.subnetID}"
  vpc_id                 = "${aws_vpc.sitebridge-vpc.id}"
  igw_id                 = "${aws_internet_gateway.sitebridge-vpc-internet-gateway.id}"
  natpool_cidr_block     = "${var.vpcNatPoolCidrBlock}"
  vpc_security_group_ids = ["${aws_security_group.subnet-1-security-group.id}"]
}

output "aws_usw2_sb_testcontroller_output" {
  value = "${module.aws_usw2_sb_testcontroller.sb_hosts_info}"
}

module "aws_usw2_sb_testcontroller_s3" {
  source       = "../output"
  region       = "${var.region}"
  cluster_info = "${var.aws_usw2_sb_testcontroller_input}"
  hosts_info   = "${module.aws_usw2_sb_testcontroller.sb_hosts_info}"
}

########################################################################

variable "instance_type" {}

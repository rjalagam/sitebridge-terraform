########################################################################
# CONTROL-PATH DATA DEFINITIONS
########################################################################

data "template_file" "cloud_config" {
  count    = "${var.numInstances}"
  template = "${file("cluster/hosts/sitebridgeNode/cloud-init/${var.cloudInitFolder[count.index]}/cloud-config.yml")}"

  vars {
    cluster_name                  = "${var.name}"
    platform_name                 = "${var.platformName}"
    kingdom_name                  = "${var.kingdomName}"
    SITEBRIDGE_BOOTSTRAPPER_IMAGE = "${var.sitebridgeImage}"
    INSECURE_TLS                  = "true"
    LIVENESS_PROBE_PORT           = 9206
    ARCHIVE_SVC_ENDPOINT          = "http://ops0-piperepo1-1-prd.eng.sfdc.net/tnrp/content_repo/0/archive"
    HOSTNAME                      = "${var.instanceNamePrefix}-${count.index+1}-${var.instanceNameSuffix}"
  }
}

########################################################################
# CONTROL-PATH MODULE DEFINITIONS
########################################################################
module "sitebridge-node-instance" {
  source                      = "../ec2Instance"
  name                        = "${var.name}"
  role                        = "node"
  instance_count              = "${var.numInstances}"
  instanceTypeList            = "${var.instanceTypeList}"
  amiList                     = "${var.amiList}"
  vpc_security_group_ids      = "${var.vpcSecurityGroupIds}"
  subnet_id                   = "${var.sitebridgeNodeSubnetId}"
  user_data                   = "${data.template_file.cloud_config.*.rendered}"
  associate_public_ip_address = false
  source_dest_check           = false
  cloudInitFolder             = "${var.cloudInitFolder}"
  externalIPs                 = "${var.externalIPs}"
  instanceNamePrefix          = "${var.instanceNamePrefix}"
  instanceNameSuffix          = "${var.instanceNameSuffix}"

  root_block_device = [{
    volume_type           = "gp2"
    volume_size           = "${var.control_root_file_size}"
    delete_on_termination = true
  }]
}

########################################################################
# Reserve a public IP pool of Instance Count
########################################################################

########################################################################
# Sitebridge Node VARIABLE DEFINITIONS
########################################################################
variable "vpcID" {}

variable "sitebridgeNodeSubnetId" {}

variable "numInstances" {}

variable "sitebridgeImage" {}

variable "amiList" {
  type = "list"
}

variable "instanceTypeList" {
  type = "list"
}

variable "name" {}

variable "kingdomName" {}

variable "platformName" {}

variable "control_root_file_size" {
  description = "EBS Size for Bastion root file system.  Default = 100"
  default     = "100"
}

variable "vpcSecurityGroupIds" {
  description = "A list of security group IDs to associate with"
  type        = "list"
}

variable "externalIPs" {
  type = "list"
}

variable "instanceNamePrefix" {}

variable "instanceNameSuffix" {}

variable "cloudInitFolder" {
  type = "list"

  default = [
    "current",
    "current",
    "current",
    "current",
  ]
}

########################################################################
# Sitebridge Node OUTPUT DEFINITIONS
########################################################################
output "instance_id" {
  description = "Control path instance id"
  value       = "${module.sitebridge-node-instance.instance_id}"
}

output "private_ip_addresses" {
  description = "List of public DNS names assigned to the instances"
  value       = "${module.sitebridge-node-instance.private_ip}"
}

output "public_ip_addresses" {
  description = "List of public DNS names assigned to the instances"
  value       = "${module.sitebridge-node-instance.public_ip}"
}

output "hostnames" {
  description = "Host names"
  value       = "${module.sitebridge-node-instance.hostname}"
}

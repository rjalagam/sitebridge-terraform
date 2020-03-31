########################################################################
# BASTION DATA DEFINITIONS
########################################################################
data "template_file" "cloud_config" {
  count    = "${var.numInstances}"
  template = "${file("${var.cloudInitFolder[count.index]}/cloud-config.yml")}"

  vars {
    HOSTNAME = "${var.instanceNamePrefix}-${count.index+1}-${var.instanceNameSuffix}"
  }
}

########################################################################
# BASTION MODULE DEFINITIONS
########################################################################
variable "name" {
  default = "bastion"
}

variable "numInstances" {
  default = "1"
}

variable "amiList" {
  type = "list"
}

variable "instanceTypeList" {
  type = "list"
}

variable "vpcSecurityGroupIds" {
  type = "list"
}

variable "subnetId" {
  default = ""
}

variable "control_root_file_size" {
  description = "EBS Size for Bastion root file system.  Default = 100"
  default     = "100"
}

variable "externalIPs" {
  type = "list"
}

variable "instanceNamePrefix" {}

variable "instanceNameSuffix" {}

variable "cloudInitFolder" {
  type = "list"

  default = [
    "bastion",
  ]
}

module "sitebridge-bastion-instance" {
  source                      = "../cluster/hosts/ec2Instance"
  name                        = "${var.name}"
  role                        = "bastion"
  instance_count              = "${var.numInstances}"
  amiList                     = "${var.amiList}"
  instanceTypeList            = "${var.instanceTypeList}"
  vpc_security_group_ids      = "${var.vpcSecurityGroupIds}"
  subnet_id                   = "${var.subnetId}"
  user_data                   = "${data.template_file.cloud_config.*.rendered}"
  associate_public_ip_address = false
  source_dest_check           = true

  cloudInitFolder    = "${var.cloudInitFolder}"
  externalIPs        = "${var.externalIPs}"
  instanceNamePrefix = "${var.instanceNamePrefix}"
  instanceNameSuffix = "${var.instanceNameSuffix}"

  root_block_device = [{
    volume_type           = "gp2"
    volume_size           = "${var.control_root_file_size}"
    delete_on_termination = true
  }]

  tags {
    Terraform = "true"
    Role      = "bastion"
  }
}

########################################################################
# Sitebridge Node OUTPUT DEFINITIONS
########################################################################
output "hosts_info" {
  value = "${map(
    "instance_ids", module.sitebridge-bastion-instance.instance_id,
    "private_ips", module.sitebridge-bastion-instance.private_ip,
    "public_ips", module.sitebridge-bastion-instance.public_ip,
    "hostnames", module.sitebridge-bastion-instance.hostname
  )}"
}

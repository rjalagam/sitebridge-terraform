########################################################################
# EC2-INSTANCE RESOURCE DEFINITIONS
########################################################################
variable "centos7_base_amis" {
  type = "map"

  default = {
    us-east-1 = "ami-04e3537b"
    us-west-2 = "ami-08e02b9cc3c192390"
  }
}

data "aws_region" "current" {}

resource "null_resource" "default_ami_list" {
  count = "${var.instance_count}"

  triggers {
    ami = "${lookup(var.centos7_base_amis, data.aws_region.current.name)}"
  }
}

variable "base_instance_types" {
  type = "map"

  default = {
    us-west-2 = "c5.4xlarge"
  }
}

resource "null_resource" "default_instance_type_list" {
  count = "${var.instance_count}"

  triggers {
    instance_type = "${lookup(var.base_instance_types, data.aws_region.current.name)}"
  }
}

locals {
  # The following is hack; need to find a cleaner way
  my_ami_list      = ["${split(",", length(var.amiList) > 0 ? join(",", var.amiList) : join(",", formatlist("%s", null_resource.default_ami_list.*.triggers.ami)))}"]
  my_instance_list = ["${split(",", length(var.instanceTypeList) > 0 ? join(",", var.instanceTypeList) : join(",", formatlist("%s", null_resource.default_instance_type_list.*.triggers.instance_type)))}"]
}

########################################################################

locals {
  use_static_address    = "${length(var.externalIPs) > 0}"
  dynamic_address_count = "${length(var.externalIPs) > 0 ? 0 : var.instance_count}"
}

data aws_eip "static_public_ips" {
  count     = "${length(var.externalIPs)}"
  public_ip = "${var.externalIPs[count.index]}"
}

# Create a network interface having a private Ip
resource "aws_network_interface" "private-eni-pool" {
  count             = "${var.instance_count}"
  subnet_id         = "${var.subnet_id[count.index]}"
  security_groups   = ["${var.vpc_security_group_ids}"]
  source_dest_check = false
  private_ips       = "${ count.index < length(var.privateIPs) ? list(var.privateIPs[count.index]) : null }"
  private_ip        = "${ count.index < length(var.privateIPs) ? var.privateIPs[count.index] : null }"
  private_ips_count = 0

  tags {
    Terraform = "true"
    Name      = "${format("%s-%d-%s-eni", var.instanceNamePrefix, count.index+1, var.instanceNameSuffix)}"
  }
}

# Create a Elastic public IP and associate to the network interface having private Ip
resource "aws_eip" "sitebridge-node-eip" {
  count = "${local.dynamic_address_count}"
  vpc   = true

  tags {
    Terraform = "true"
    Name      = "${format("%s-%d-%s-eip", var.instanceNamePrefix, count.index+1, var.instanceNameSuffix)}"
  }
}

resource "null_resource" "instance-name" {
  count = "${var.instance_count}"

  triggers {
    hostname = "${format("%s-%d-%s", var.instanceNamePrefix, count.index+1, var.instanceNameSuffix)}"
  }
}

resource "aws_eip_association" "sitebridge-node-eip-association" {
  count         = "${var.instance_count}"
  instance_id   = "${aws_instance.instance.*.id[count.index]}"
  allocation_id = "${element(coalescelist(data.aws_eip.static_public_ips.*.id, aws_eip.sitebridge-node-eip.*.id),count.index)}"
}

# Create a instance with above network interface having private Ip, Public Ip already associated.
resource "aws_instance" "instance" {
  count = "${var.instance_count}"

  ami           = "${local.my_ami_list[count.index]}"
  instance_type = "${local.my_instance_list[count.index]}"
  user_data     = "${var.user_data[count.index]}"

  key_name   = "${var.key_name}"
  monitoring = "${var.monitoring}"

  iam_instance_profile = "${var.iam_instance_profile}"

  ebs_optimized          = "${var.ebs_optimized}"
  volume_tags            = "${var.volume_tags}"
  root_block_device      = "${var.root_block_device}"
  ebs_block_device       = "${var.ebs_block_device}"
  ephemeral_block_device = "${var.ephemeral_block_device}"

  disable_api_termination              = "${var.disable_api_termination}"
  instance_initiated_shutdown_behavior = "${var.instance_initiated_shutdown_behavior}"
  placement_group                      = "${var.placement_group}"
  tenancy                              = "${var.tenancy}"

  #"${var.instanceNamePrefix}-${count.index+1}-${var.instanceNameSuffix}"
  tags = "${merge(var.tags, map("Name", format("%s-%d-%s", var.instanceNamePrefix, count.index+1, var.instanceNameSuffix)))}"

  depends_on = ["aws_network_interface.private-eni-pool"]

  network_interface {
    network_interface_id = "${aws_network_interface.private-eni-pool.*.id[count.index]}"
    device_index         = 0
  }

  lifecycle {
    # Due to several known issues in Terraform AWS provider related to arguments of aws_instance:
    # (eg, https://github.com/terraform-providers/terraform-provider-aws/issues/2036)
    # we have to ignore changes in the following arguments
    ignore_changes = ["private_ip", "root_block_device", "associate_public_ip_address"]
  }
}

########################################################################
# EC2-INSTANCE VARIABLE DEFINITIONS
########################################################################

variable "name" {
  description = "Name to be used on all resources as prefix"
}

variable "role" {
  description = "Role to be used on all resources as prefix"
}

variable "instance_count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "amiList" {
  description = "List of ID of AMI to use for the instance"
  type        = "list"
}

variable "instanceTypeList" {
  description = "List of instance types to use for the instance"
  type        = "list"
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance" # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
  default     = ""
}

variable "key_name" {
  description = "The key name to use for the instance"
  default     = "aws-sb-poc"
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = "list"
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  default     = ""
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = "list"
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = "sdn-sb-prod-role"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = "map"
  default     = {}
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = "map"
  default     = {}
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = "list"
  default     = []
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = "list"
  default     = []
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  type        = "list"
  default     = []
}

variable "externalIPs" {
  type = "list"
}

variable "instanceNamePrefix" {}

variable "instanceNameSuffix" {}

variable "cloudInitFolder" {
  type = "list"
}

########################################################################
# EC2-INSTANCE OUTPUT DEFINITIONS
########################################################################
locals {
  this_host_names  = "${compact(concat(null_resource.instance-name.*.triggers.hostname))}"
  this_instance_id = "${compact(concat(aws_instance.instance.*.id))}"
  this_private_ip  = "${compact(concat(aws_instance.instance.*.private_ip))}"
  this_public_ip   = "${compact(concat(coalescelist(data.aws_eip.static_public_ips.*.public_ip, aws_eip.sitebridge-node-eip.*.public_ip)))}"
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = ["${local.this_instance_id}"]
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = "${local.this_private_ip}"
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances"
  value       = "${local.this_public_ip}"
}

output "hostname" {
  description = "List of hostnames assigned to the instances"
  value       = "${local.this_host_names}"
}

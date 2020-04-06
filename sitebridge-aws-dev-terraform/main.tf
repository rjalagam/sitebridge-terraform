########################################################################
# Build Sitebridge VPCs in each region
########################################################################

# Build VPC and Subnets in us-west-2
module "sb-us-west-2" {
  source        = "us-west-2"
  instance_type = "${var.instance_type}"
}

variable "instance_type" {
  default = "c5.4xlarge"
}

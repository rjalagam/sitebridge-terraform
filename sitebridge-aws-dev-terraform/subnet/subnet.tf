########################################################################
# Subnet Module
########################################################################

###############################################
# Input Definitions
###############################################
variable "vpc_id" {
  default = ""
}

variable "subnet_cidr" {
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}

variable "tags" {
  default = {}
  type    = "map"
}

variable "igw_id" {
  type = "string"
}

variable "subnet_name" {
  type        = "string"
  description = "Name to be used on a resource as cluster name as prefix"
}

##############################################
# Subnet Resource Definitions
#############################################
resource "aws_subnet" "sitebridge-subnet" {
  count                   = ${length(var.subnet_cidr)}
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.subnet_cidr[count.index]}"
  availability_zone       = "${var.availability_zone[count.index]}"
  tags                    = "${merge(var.tags, map("Name", format("%s", "${var.subnet_name}")))}"
  map_public_ip_on_launch = false
}

#--------------------------------------
# Create the Route Table. At this time you cannot use a Route Table with in-line routes in conjunction with
# any Route resources. Doing so will cause a conflict of rule settings and will overwrite rules.
# Specify any routes one by one via the aws_route resource.
#--------------------------------------
resource "aws_route_table" "sitebridge-subnet-route-table" {
  vpc_id = "${var.vpc_id}"
  tags   = "${merge(var.tags, map("Name", format("%s-%s", "${var.subnet_name}", "route-table")))}"
}

variable "internetCIDRBlock" {
  default = "0.0.0.0/0"
}

resource "aws_route" "sitebridge-internet-access" {
  route_table_id         = "${aws_route_table.sitebridge-subnet-route-table.id}"
  destination_cidr_block = "${var.internetCIDRBlock}"
  gateway_id             = "${var.igw_id}"
}

# Associate the newly created subnet to above route-table
resource "aws_route_table_association" "sitebridge-subnet-route-table-association" {
  subnet_id      = "${aws_subnet.sitebridge-subnet.id}"
  route_table_id = "${aws_route_table.sitebridge-subnet-route-table.id}"
}

#############################################
# Output Definitions
#############################################
# Subnets
output "subnetID" {
  description = "List of IDs of private subnets"
  value       = "${aws_subnet.sitebridge-subnet.*.id}"
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = ["${aws_subnet.sitebridge-subnet.*.cidr_block}"]
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = ["${aws_route_table.sitebridge-subnet-route-table.id}"]
}

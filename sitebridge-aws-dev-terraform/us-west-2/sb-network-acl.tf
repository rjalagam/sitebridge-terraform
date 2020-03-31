########################################################################
#
# Network access control lists (ACLs) —
#   Act as a firewall for associated subnets, controlling
#   both inbound and outbound traffic at the subnet level
#
# Security groups —
#   Act as a firewall for associated Amazon EC2 instances,
#   controlling both inbound and outbound traffic at the instance level
#
# For differences between security group and network ACL:
#   https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html
# Rules for Network ACL: Default number of ingress and egress rules is 20.
#
#
########################################################################
# SFDC Corporate CIDRS
variable "sfdcCIDRs" {
  type = "list"

  default = [
    "13.108.0.0/14",
    "96.43.144.0/20",
    "136.146.0.0/15",
    "204.14.232.0/21",
    "85.222.128.0/19",
    "185.79.140.0/22",
    "101.53.160.0/19",
    "182.50.76.0/22",
    "202.129.242.0/23",
  ]
}

########################################################################
# 1. Create a Network ACL for the bastion subnet. Limit rules count to ingress:20, egress:20
########################################################################
resource "aws_network_acl" "subnet-0-network-acl" {
  vpc_id = "${aws_vpc.sitebridge-vpc.id}"

  subnet_ids = [
    "${module.subnet-0.subnetID}",
  ]

  tags {
    Name = "sitebridge-prod-aws-usw-2-vpc-1-subnet-0-network-acl"
  }
}

resource "aws_network_acl_rule" "subnet-0-nacl-egress-allow-all" {
  network_acl_id = "${aws_network_acl.subnet-0-network-acl.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "${var.anyCIDRBlock}"
  from_port      = "0"
  to_port        = "0"
}

resource "aws_network_acl_rule" "subnet-0-nacl-ingress-allow-ssh-from-local" {
  network_acl_id = "${aws_network_acl.subnet-0-network-acl.id}"
  rule_number    = "200"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.vpcCidrBlock}"
  from_port      = "22"
  to_port        = "22"
}

resource "aws_network_acl_rule" "subnet-0-nacl-ingress-allow-ssh-from-corp" {
  network_acl_id = "${aws_network_acl.subnet-0-network-acl.id}"
  count          = "${length(var.sfdcCIDRs)}"
  rule_number    = "${201 + count.index}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${element(var.sfdcCIDRs, count.index)}"
  from_port      = "22"
  to_port        = "22"
}

resource "aws_network_acl_rule" "subnet-0-nacl-ingress-deny-ssh-from-rest" {
  network_acl_id = "${aws_network_acl.subnet-0-network-acl.id}"
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "${var.anyCIDRBlock}"
  from_port      = "22"
  to_port        = "22"
}

resource "aws_network_acl_rule" "subnet-0-nacl-ingress-allow-all" {
  network_acl_id = "${aws_network_acl.subnet-0-network-acl.id}"
  rule_number    = 5000
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "${var.anyCIDRBlock}"
  from_port      = "0"
  to_port        = "0"
}

########################################################################
# 1. Create a Network ACL for the sitebridge subnet having clusters. Limit rules count to ingress:20, egress:20
########################################################################
resource "aws_network_acl" "subnet-1-network-acl" {
  vpc_id = "${aws_vpc.sitebridge-vpc.id}"

  subnet_ids = [
    "${module.subnet-1.subnetID}",
  ]

  tags {
    Name = "sitebridge-dev-aws-usw2-vpc1-subnet1-network-acl"
  }
}

resource "aws_network_acl_rule" "subnet-1-nacl-egress-allow-all" {
  network_acl_id = "${aws_network_acl.subnet-1-network-acl.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "${var.anyCIDRBlock}"
  from_port      = "0"
  to_port        = "0"
}

resource "aws_network_acl_rule" "subnet-1-nacl-ingress-allow-ssh-from-bastion" {
  network_acl_id = "${aws_network_acl.subnet-1-network-acl.id}"
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.subnet0CIDR}"
  from_port      = "22"
  to_port        = "22"
}

resource "aws_network_acl_rule" "subnet-1-nacl-ingress-deny-ssh-from-rest" {
  network_acl_id = "${aws_network_acl.subnet-1-network-acl.id}"
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "${var.anyCIDRBlock}"
  from_port      = "22"
  to_port        = "22"
}

resource "aws_network_acl_rule" "subnet-1-nacl-ingress-allow-all" {
  network_acl_id = "${aws_network_acl.subnet-1-network-acl.id}"
  rule_number    = 5000
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "${var.anyCIDRBlock}"
  from_port      = "0"
  to_port        = "0"
}

########################################################################
# 2. Create a Network ACL for the sitebridge subnet having clusters. Limit rules count to ingress:20, egress:20
########################################################################
resource "aws_network_acl" "subnet-2-network-acl" {
  vpc_id = "${aws_vpc.sitebridge-vpc.id}"

  subnet_ids = [
    "${module.subnet-2.subnetID}",
  ]

  tags {
    Name = "sitebridge-dev-aws-usw2-vpc1-subnet2-network-acl"
  }
}

resource "aws_network_acl_rule" "subnet-2-nacl-egress-allow-all" {
  network_acl_id = "${aws_network_acl.subnet-2-network-acl.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "${var.anyCIDRBlock}"
  from_port      = "0"
  to_port        = "0"
}

resource "aws_network_acl_rule" "subnet-2-nacl-ingress-allow-ssh-from-bastion" {
  network_acl_id = "${aws_network_acl.subnet-2-network-acl.id}"
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${var.subnet0CIDR}"
  from_port      = "22"
  to_port        = "22"
}

resource "aws_network_acl_rule" "subnet-2-nacl-ingress-deny-ssh-from-rest" {
  network_acl_id = "${aws_network_acl.subnet-2-network-acl.id}"
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "${var.anyCIDRBlock}"
  from_port      = "22"
  to_port        = "22"
}

resource "aws_network_acl_rule" "subnet-2-nacl-ingress-allow-all" {
  network_acl_id = "${aws_network_acl.subnet-2-network-acl.id}"
  rule_number    = 5000
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "${var.anyCIDRBlock}"
  from_port      = "0"
  to_port        = "0"
}

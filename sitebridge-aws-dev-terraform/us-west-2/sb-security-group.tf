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
########################################################################

########################################################################
# 0. Create a Security Group to be attached to all Bastion Instances
########################################################################
resource "aws_security_group" "subnet-0-bastion-sg" {
  name        = "${var.vpcName}-subnet-0-bastion-sg"
  description = "${var.vpcName}-subnet-0-bastion-sg"
  vpc_id      = "${aws_vpc.sitebridge-vpc.id}"

  tags {
    Name = "${var.vpcName}-subnet-0-bastion-sg"
  }
}

resource "aws_security_group_rule" "subnet-0-ingress-allow-all-icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["${var.sfdcCIDRs}"]
  security_group_id = "${aws_security_group.subnet-0-bastion-sg.id}"
  description       = "Allow all ICMP traffic from bastion subnet"
}

resource "aws_security_group_rule" "subnet-0-ingress-allow-ssh-from-corp" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = "${var.sfdcCIDRs}"
  security_group_id = "${aws_security_group.subnet-0-bastion-sg.id}"
  description       = "Allow all ssh traffic from bastion subnet"
}

resource "aws_security_group_rule" "subnet-0-egress-allow-all" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["${var.anyCIDRBlock}"]
  security_group_id = "${aws_security_group.subnet-0-bastion-sg.id}"
  description       = "Allow all outgoing traffic to bastion subnet"
}

########################################################################
# 1. Create a Security Group to be attached to all Sitebridge Instances
########################################################################
resource "aws_security_group" "subnet-1-security-group" {
  name        = "sitebridge-dev-aws-usw-2-vpc-1-subnet-1-security-group"
  description = "sitebridge-dev-aws-usw-2-vpc-1-subnet-1-security-group"
  vpc_id      = "${aws_vpc.sitebridge-vpc.id}"

  tags {
    Name = "sitebridge-dev-aws-usw-2-vpc-1-subnet-1-security-group"
  }
}

resource "aws_security_group_rule" "subnet-1-ingress-allow-all-icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["${var.subnet0CIDR}", "${var.subnet1CIDR}", "${distinct(concat(var.remoteSitebridgeCIDRs, var.remoteVPGCIDRs))}"]
  security_group_id = "${aws_security_group.subnet-1-security-group.id}"
  description       = "Allow all ICMP traffic from bastion subnet, subnet1, and remote Sitebridge subnets"
}

resource "aws_security_group_rule" "subnet-1-ingress-allow-ssh-from-bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.subnet0CIDR}"]
  security_group_id = "${aws_security_group.subnet-1-security-group.id}"
  description       = "Allow all ssh traffic from bastion subnet"
}

# Add below any remote sitebridge public Ip / Cidr where IPSEC communication will be received from
variable "remoteSitebridgeCIDRs" {
  type = "list"

  default = [
    "136.146.50.0/27",    // PRD
    "136.146.50.32/27",   // XRD
    "35.233.167.103/32",  // GCP us-west
    "104.199.117.137/32",
    "35.199.161.84/32",
    "35.197.83.36/32",
    "35.199.156.214/32",
    "35.230.5.68/32",
    "35.185.213.98/32",
    "35.203.157.35/32",
    "35.203.139.72/32",
    "35.233.169.81/32",
    "35.233.227.10/32",   // GCP delta
    "3.17.233.90/32",     // AWS falcon test; TODO: update after EIP block(s) is allocated
    "3.14.123.117/32",    // AWS falcon test; TODO: update after EIP block(s) is allocated
    "18.221.14.41/32",    // AWS falcon test; TODO: update after EIP block(s) is allocated
  ]
}

# Add below any customer vpg public Ip / Cidr where IPSEC communication will be received from
variable "remoteVPGCIDRs" {
  type = "list"

  default = []
}

resource "aws_security_group_rule" "subnet-1-ingress-allow-ipsec-from-remote-500" {
  type              = "ingress"
  from_port         = 500
  to_port           = 500
  protocol          = "udp"
  cidr_blocks       = "${distinct(concat(var.remoteSitebridgeCIDRs, var.remoteVPGCIDRs))}"
  security_group_id = "${aws_security_group.subnet-1-security-group.id}"
  description       = "Allow isakmp port 500 for PHASE 1 of IPSEC tunnnel from remote sitebridge"
}

resource "aws_security_group_rule" "subnet-1-ingress-allow-ipsec-from-remote-4500" {
  type              = "ingress"
  from_port         = 4500
  to_port           = 4500
  protocol          = "udp"
  cidr_blocks       = "${distinct(concat(var.remoteSitebridgeCIDRs, var.remoteVPGCIDRs))}"
  security_group_id = "${aws_security_group.subnet-1-security-group.id}"
  description       = "Allow esp port 4500 for IPSEC traffic from remote sitebridge"
}

resource "aws_security_group_rule" "subnet-1-ingress-allow-dns-from-remote-9443" {
  type              = "ingress"
  from_port         = 9443
  to_port           = 9443
  protocol          = "tcp"
  cidr_blocks       = "${distinct(concat(var.remoteSitebridgeCIDRs, var.remoteVPGCIDRs))}"
  security_group_id = "${aws_security_group.subnet-1-security-group.id}"
  description       = "Allow DNS communication to port 9443 from remote DNS"
}

resource "aws_security_group_rule" "subnet-1-security-group-ingress-allow-udp-dns" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["${var.subnet1CIDR}"]
  security_group_id = "${aws_security_group.subnet-1-security-group.id}"
  description       = "Allow UDP DNS communication for intracluster perf testing"
}

resource "aws_security_group_rule" "subnet-1-security-group-ingress-allow-etcd-comm" {
  type              = "ingress"
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  cidr_blocks       = ["${var.subnet1CIDR}"]
  security_group_id = "${aws_security_group.subnet-1-security-group.id}"
  description       = "Allow ETCD communication"
}

resource "aws_security_group_rule" "subnet-1-security-group-ingress-allow-grpc-liveness-probe" {
  type              = "ingress"
  from_port         = 9203
  to_port           = 9214
  protocol          = "tcp"
  cidr_blocks       = ["${var.subnet1CIDR}"]
  security_group_id = "${aws_security_group.subnet-1-security-group.id}"
  description       = "Allow GRPC liveness health probe ports"
}

resource "aws_security_group_rule" "subnet-1-egress-allow-all" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["${var.anyCIDRBlock}"]
  security_group_id = "${aws_security_group.subnet-1-security-group.id}"
  description       = "Allow all outgoing traffic to bastion subnet, subnet1, and remote Sitebridge subnets"
}

########################################################################
# 2. Create a Security Group to be attached to all Subnet 2 Instances
########################################################################
resource "aws_security_group" "subnet-2-security-group" {
  name        = "sitebridge-dev-aws-usw-2-vpc-1-subnet-2-security-group"
  description = "sitebridge-dev-aws-usw-2-vpc-1-subnet-2-security-group"
  vpc_id      = "${aws_vpc.sitebridge-vpc.id}"

  tags {
    Name = "sitebridge-dev-aws-usw-2-vpc-1-subnet-2-security-group"
  }
}

resource "aws_security_group_rule" "subnet-2-ingress-allow-all-icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["${var.subnet0CIDR}", "${var.subnet1CIDR}", "${var.subnet2CIDR}", "${distinct(concat(var.remoteSitebridgeCIDRs, var.remoteVPGCIDRs))}"]
  security_group_id = "${aws_security_group.subnet-2-security-group.id}"
  description       = "Allow all ICMP traffic from bastion subnet, subnet1, subnet2, and remote SB subnets"
}

resource "aws_security_group_rule" "subnet-2-ingress-allow-ssh-from-bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.subnet0CIDR}"]
  security_group_id = "${aws_security_group.subnet-2-security-group.id}"
  description       = "Allow all ssh traffic from bastion subnet"
}

resource "aws_security_group_rule" "subnet-2-security-group-ingress-allow-etcd-comm" {
  type              = "ingress"
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  cidr_blocks       = ["${var.subnet1CIDR}", "${var.subnet2CIDR}"]
  security_group_id = "${aws_security_group.subnet-2-security-group.id}"
  description       = "Allow ETCD communication"
}

resource "aws_security_group_rule" "subnet-2-security-group-ingress-allow-grpc-liveness-probe" {
  type              = "ingress"
  from_port         = 9203
  to_port           = 9214
  protocol          = "tcp"
  cidr_blocks       = ["${var.subnet2CIDR}"]
  security_group_id = "${aws_security_group.subnet-2-security-group.id}"
  description       = "Allow GRPC liveness health probe ports"
}

resource "aws_security_group_rule" "subnet-2-egress-allow-all" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["${var.anyCIDRBlock}"]
  security_group_id = "${aws_security_group.subnet-2-security-group.id}"
  description       = "Allow all outgoing traffic to bastion subnet, subnet1, subnet2, and remote SB subnets"
}

# Hosted Zone IDs
variable "in-addr-arpa-zone-id" {
  default = "ZEKEBT3D5NDLI"
}

variable "awssb-sfdcsb-zone-id" {
  default = "ZJ4LLWXSW1AHN"
}

variable "gcpsb-sfdcsb-zone-id" {
  default = "Z2I4WSQUX738LC"
}

variable "vpc_id" {}

resource "aws_route53_zone_association" "in-addr-arpa-association" {
  zone_id = "${var.in-addr-arpa-zone-id}"
  vpc_id  = "${var.vpc_id}"
}

resource "aws_route53_zone_association" "awssb-sfdcsb-association" {
  zone_id = "${var.awssb-sfdcsb-zone-id}"
  vpc_id  = "${var.vpc_id}"
}

resource "aws_route53_zone_association" "gcpsb-sfdcsb-association" {
  zone_id = "${var.gcpsb-sfdcsb-zone-id}"
  vpc_id  = "${var.vpc_id}"
}

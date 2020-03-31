/*
Define in each VPC?
resource "aws_flow_log" "example" {
  iam_role_arn    = "${aws_iam_role.example.arn}"
  log_destination = "${aws_cloudwatch_log_group.example.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${aws_vpc.example.id}"
}
*/

resource "aws_cloudwatch_log_group" "Trust-Netflow" {
  name              = "Trust-Netflow"
  retention_in_days = 7
}

resource "aws_iam_role" "flowlogsRole" {
  name = "flowlogsRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flowlogsPolicy" {
  name = "flowlogsPolicy"
  role = "${aws_iam_role.flowlogsRole.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

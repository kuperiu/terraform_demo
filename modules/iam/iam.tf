variable "service_name" {}

#auto scaling group iam resources
data "aws_iam_policy_document" "service_policy" {
  statement {
    sid = "1"

    actions = [
        "autoscaling:Describe*",
        "autoscaling:EnterStandby",
        "autoscaling:ExitStandby",
        "cloudformation:Describe*",
        "cloudformation:GetTemplate",
        "s3:Get*"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "asg_iam_policy" {
  name   = "${var.service_name}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.service_policy.json}"
}

resource "aws_iam_role" "asg_iam_role" {
  name = "${var.service_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "asg_iam_role_policy_attachment" {
  role       = "${var.service_name}"
  policy_arn = "${aws_iam_policy.asg_iam_policy.arn}"
}

resource "aws_iam_instance_profile" "asg_iam_profile" {
  name = "${var.service_name}"
  role = "${aws_iam_role.asg_iam_role.name}"
}

resource "aws_iam_role" "basic_app_role" {
  name = "${var.service_name}_deploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#code deployg group iam resources
resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = "${aws_iam_role.basic_app_role.name}"
}

output "asg_iam_profile_id" {
  value = "${aws_iam_instance_profile.asg_iam_profile.id}"
}

output "app_iam_role_arn" {
  value = "${aws_iam_role.basic_app_role.arn}"
}

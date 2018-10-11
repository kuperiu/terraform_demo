variable "service_name" {}

data "aws_iam_policy_document" "service_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::lior",
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

output "basic_iam_id" {
  value = "${aws_iam_instance_profile.asg_iam_profile.id}"
}

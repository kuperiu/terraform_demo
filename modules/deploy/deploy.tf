variable "service_name" {}
variable "elb_name" {}
variable "asg" {}

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

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = "${aws_iam_role.basic_app_role.name}"
}

resource "aws_codedeploy_app" "basic_app" {
  name = "${var.service_name}"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = "${var.service_name}"
  deployment_group_name = "${var.service_name}"
  service_role_arn      = "${aws_iam_role.basic_app_role.arn}"
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  autoscaling_groups = ["${var.asg}"]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    elb_info {
      name = "${var.service_name}"
    }
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
    }
  }
}


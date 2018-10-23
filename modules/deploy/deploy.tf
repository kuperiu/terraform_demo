variable "service_name" {}
variable "elb_name" {}
variable "asg" {}

variable "code_deploy_role_arn" {}

resource "aws_codedeploy_app" "basic_app" {
  name = "${var.service_name}"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name               = "${var.service_name}"
  deployment_group_name  = "${var.service_name}"
  service_role_arn       = "${var.code_deploy_role_arn}"
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  autoscaling_groups     = ["${var.asg}"]


  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    elb_info {
      name = "${var.elb_name}"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

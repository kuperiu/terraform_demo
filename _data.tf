data "template_file" "user_data" {
  template = "${file("userdata.tpl")}"
}

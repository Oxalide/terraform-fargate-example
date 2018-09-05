module "container" {
  source         = ".."
  prefix         = "example"
  aws_region     = "${var.aws_region}"
  aws_account_id = "${var.aws_account_id}"
  app_image      = "nginx"
  app_port       = 80
  app_count      = 1
  assign_public_ip = "false"
  aws_security_group_id = "${var.aws_security_group_id}"
  aws_subnet_ids = ["${var.aws_subnet_ids}"]

  # Be carefull to select compatible values
  # https://medium.com/prodopsio/deploying-fargate-services-using-cloudformation-the-guide-i-wish-i-had-d89b6dc62303
  fargate_cpu    = 512
  fargate_memory = 1024
}

# Fargate with Terraform

Terraform scripts to deploy an ECS cluster.
You can use any image you like.
Creates cluster with single service.

## Example

```hcl
# Deploys image to Fargate
module "deploy_app" {
  source = "github.com/huksley/terraform-aws-fargate?ref=1.0_GA"

  # NOTE: Some resources of AWS have limit on 32 symbols for names, prefix + name must not exceed what!
  prefix     = "${var.namespace}-${var.app}-ps-${var.stage}"
  aws_region = "${var.aws_region}"

  # AWS Account ID - as displayed on https://console.aws.amazon.com/billing/home?#/account
  aws_account_id = "${var.aws_account_id}"
  app_image      = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.namespace}-${var.app}-ps-${var.stage}:lates
  app_port       = 8080
  app_count      = 1

  # Be careful to select compatible values
  # https://medium.com/prodopsio/deploying-fargate-services-using-cloudformation-the-guide-i-wish-i-had-d89b6dc62303
  fargate_cpu             = 512
  fargate_memory          = 1024
  aws_security_group_id   = "${module.build_vpc.aws_security_group_id}"
  aws_subnet_ids          = "${module.build_vpc.aws_private_subnet_ids}"
  aws_alb_target_group_id = "${aws_alb_target_group.ps_app.id}"
  container_env   = <<END_OF_JSON
[
    { "name": "SPRING_PROFILES_ACTIVE", "value": "aws" }
]
END_OF_JSON
}

```

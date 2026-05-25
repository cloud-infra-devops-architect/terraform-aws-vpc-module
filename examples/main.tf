# ─── EXAMPLE: terraform-aws-vpc module usage ────────────────────────────────
#
# This example shows all required and optional inputs, and captures all outputs.
# Run:
#   terraform init
#   terraform plan
#   terraform apply

terraform {
  required_version = "~> 1.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.46.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "github.com/cloud-infra-devops/terraform-aws-vpc-module?ref=v1.0.2"

  # ── Required inputs ────────────────────────────────────────────────────────
  aws_region = "us-east-1"
  vpc_cidr   = "10.0.0.0/16"

  # ── Optional: naming & tagging ─────────────────────────────────────────────
  name        = "duke-aim-ima"
  environment = "dev"
  project     = "duke-data-aim-ima"
  owner       = "cloud-infra-devops"
  email       = "cloud-infra-devops@duke-energy.com"

  # ── Optional: subnet layout ────────────────────────────────────────────────
  num_public_subnets  = 3         # one per AZ
  num_private_subnets = 3         # subnets per layer, per AZ
  num_layers          = 2         # layer-1 = app, layer-2 = db
  instance_tenancy    = "default" # "default" | "dedicated" | "host"

  # ── Optional: secondary CIDR (set to null to skip) ─────────────────────────
  secondary_vpc_cidr = "100.64.0.0/16"

  # ── Optional: DNS settings ─────────────────────────────────────────────────
  enable_dns_hostnames = true
  enable_dns_support   = true

  # ── Optional: NAT Gateway ──────────────────────────────────────────────────
  # Routes to 0.0.0.0/0 on private subnets are created ONLY when this is true.
  create_nat_gateway = true
  single_nat_gateway = false # false = one NAT GW per AZ; true = single shared NAT GW

  # ── Optional: VPC Flow Logs ────────────────────────────────────────────────
  enable_flow_logs = true

  # ── Optional: CloudWatch alarm notifications ───────────────────────────────
  # Provide SNS topic ARNs to receive alarm notifications.
  # Leave as [] to create alarms without notification actions.
  cloudwatch_alarm_actions = []
}

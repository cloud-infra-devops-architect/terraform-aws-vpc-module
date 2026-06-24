# 🌐 terraform-aws-vpc

A Terraform module that creates a production-ready **AWS VPC** 🏗️ with public/private subnets across multiple layers, optional NAT Gateway, optional VPC Flow Logs, and CloudWatch alarms.

## ✨ Features

- 🌐 **VPC** with optional secondary CIDR block
- 🌍 **Public subnets** with Internet Gateway (IGW)
- 🔒 **Private subnets** across N layers (e.g. app, db, cache)
- 🔀 **NAT Gateway** (single or one-per-AZ) — routes to `0.0.0.0/0` on private subnets created **only when NAT is enabled**
- 📋 **VPC Flow Logs** → ☁️ CloudWatch Logs
- 🔔 **CloudWatch alarms** for NAT Gateway metrics and flow log delivery errors

## 🚀 Usage

```hcl
terraform {
  required_version = ">= 1.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "github.com/cloud-infra-devops/terraform-aws-vpc-module?ref=v1.0.2"

  # ── Required inputs ────────────────────────────────────────────────────────
  aws_region = "us-west-2"
  vpc_cidr   = "10.0.0.0/16"

  # ── Optional: naming & tagging ─────────────────────────────────────────────
  name        = "duke-aim-ima"
  environment = "dev"
  owner       = "cloud-infra-devops"
  project     = "duke-data-aim-ima"

  tags = {
    Email = "cloud-infra-devops@duke-energy.com"
    Team  = "Cloud DevOps Platform Engineering"
  }

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
  create_nat_gateway = false
  single_nat_gateway = false # false = one NAT GW per AZ; true = single shared NAT GW

  # ── Optional: VPC Flow Logs ────────────────────────────────────────────────
  enable_flow_logs = true

  # ── Optional: CloudWatch alarm notifications ───────────────────────────────
  # Provide SNS topic ARNs to receive alarm notifications.
  # Leave as [] to create alarms without notification actions.
  cloudwatch_alarm_actions = []
}

# ─── OUTPUTS ────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "Primary CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "secondary_cidr_block" {
  description = "Secondary CIDR block (null if not created)"
  value       = module.vpc.secondary_cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "All private subnet IDs across all layers"
  value       = module.vpc.private_subnet_ids
}

output "private_subnet_ids_by_layer" {
  description = "Map of layer number → list of private subnet IDs"
  value       = module.vpc.private_subnet_ids_by_layer
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs (empty list if create_nat_gateway = false)"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "Elastic IPs assigned to NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = module.vpc.private_route_table_ids
}

output "flow_log_id" {
  description = "VPC Flow Log ID (null if enable_flow_logs = false)"
  value       = module.vpc.flow_log_id
}

output "flow_log_cloudwatch_log_group" {
  description = "CloudWatch Log Group name for flow logs (null if enable_flow_logs = false)"
  value       = module.vpc.flow_log_cloudwatch_log_group
}

```

## 📥 Input Variables

| Name                       | Description                            | Type           | Default     | Required |
| -------------------------- | -------------------------------------- | -------------- | ----------- | :------: |
| `aws_region`               | 🌍 AWS region                           | `string`       | —           |  ✅ yes   |
| `name`                     | 🏷️ Name prefix for all resources        | `string`       | `"vpc"`     |    no    |
| `vpc_cidr`                 | 🌐 Primary VPC CIDR block               | `string`       | —           |  ✅ yes   |
| `secondary_vpc_cidr`       | 🌐 Secondary VPC CIDR (null to skip)    | `string`       | `null`      |    no    |
| `num_public_subnets`       | 🌍 Number of public subnets             | `number`       | `2`         |    no    |
| `num_private_subnets`      | 🔒 Number of private subnets per layer  | `number`       | `2`         |    no    |
| `num_layers`               | 🗂️ Number of private subnet layers      | `number`       | `1`         |    no    |
| `instance_tenancy`         | 🖥️ VPC tenancy (default/dedicated/host) | `string`       | `"default"` |    no    |
| `create_nat_gateway`       | 🔀 Create NAT Gateway                   | `bool`         | `true`      |    no    |
| `single_nat_gateway`       | 🔀 Use one NAT GW instead of one per AZ | `bool`         | `false`     |    no    |
| `enable_flow_logs`         | 📋 Enable VPC Flow Logs                 | `bool`         | `true`      |    no    |
| `flow_logs_retention_days` | 🗓️ Flow log CloudWatch retention days   | `number`       | `30`        |    no    |
| `enable_dns_hostnames`     | 🔍 Enable DNS hostnames                 | `bool`         | `true`      |    no    |
| `enable_dns_support`       | 🔍 Enable DNS support                   | `bool`         | `true`      |    no    |
| `cloudwatch_alarm_actions` | 🔔 SNS ARNs for alarm notifications     | `list(string)` | `[]`        |    no    |
| `tags`                     | 🏷️ Common tags                          | `map(string)`  | `{}`        |    no    |

## 📤 Outputs

| Name                            | Description                                    |
| ------------------------------- | ---------------------------------------------- |
| `vpc_id`                        | 🌐 VPC ID                                       |
| `vpc_cidr_block`                | 🌐 Primary CIDR                                 |
| `secondary_cidr_block`          | 🌐 Secondary CIDR (if created)                  |
| `internet_gateway_id`           | 🌍 IGW ID                                       |
| `public_subnet_ids`             | 🌍 Public subnet IDs                            |
| `private_subnet_ids`            | 🔒 All private subnet IDs                       |
| `private_subnet_ids_by_layer`   | 🗂️ Map of layer → subnet IDs                    |
| `nat_gateway_ids`               | 🔀 NAT Gateway IDs                              |
| `nat_gateway_public_ips`        | 🔀 NAT Gateway Elastic IPs                      |
| `public_route_table_id`         | 🛣️ Public route table ID                        |
| `private_route_table_ids`       | 🛣️ Private route table IDs                      |
| `flow_log_id`                   | 📋 Flow Log ID (null if disabled)               |
| `flow_log_cloudwatch_log_group` | ☁️ CloudWatch Log Group name (null if disabled) |

## 🔔 CloudWatch Alarms

The following alarms are created automatically:

**🔀 Per NAT Gateway** (created only when `create_nat_gateway = true`):
- ⚠️ `ErrorPortAllocation` — SNAT port exhaustion (threshold: > 0)
- 📦 `PacketsDropCount` — dropped packets (threshold: > 100)
- 🔗 `ConnectionAttemptCount` — high connection attempts (threshold: > 100,000 per 5 min)
- 🔗 `ConnectionEstablishedCount` — zero established connections (threshold: < 1)
- 📤 `BytesOutToDestination` — high egress bytes (threshold: > 10 GB per 5 min)
- 📥 `BytesInFromDestination` — high ingress bytes (threshold: > 10 GB per 5 min)

**📋 Flow Logs** (created only when `enable_flow_logs = true`):
- ❌ `DeliveryErrors` — flow log delivery failures
- 🚦 `ThrottledEvents` — flow log throttling

## 🗺️ Subnet CIDR Layout

Subnets are carved from the VPC CIDR using `/24` blocks (`cidrsubnet(vpc_cidr, 8, index)`):

```
Index 0..N-1          → 🌍 public subnets
Index N..N+L*P-1      → 🔒 private subnets (L layers × P subnets each)
```

For a `10.0.0.0/16` VPC with 3 public + 2 layers × 3 private:
```
10.0.0.0/24  🌍 public-1
10.0.1.0/24  🌍 public-2
10.0.2.0/24  🌍 public-3
10.0.3.0/24  🔒 private-layer1-1
10.0.4.0/24  🔒 private-layer1-2
10.0.5.0/24  🔒 private-layer1-3
10.0.6.0/24  🔒 private-layer2-1
10.0.7.0/24  🔒 private-layer2-2
10.0.8.0/24  🔒 private-layer2-3
```

## 🔄 CI/CD Pipeline Workflow Diagram

The workflow `iac-code-quality-checks` (`.github/workflows/iac-code-scan.yml`) enforces a **gate-based pipeline** — no stage proceeds unless all upstream gates pass.

### 🚦 Triggers

| Event           | Branches                               | Condition                                                                                                                                               |
| --------------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `push`          | feature branches only                  | protected branches (`main`, `master`, `develop`, `release`) are blocked via `branches-ignore` + `guard-direct-push` job; ignores `**/README.md` changes |
| `pull_request`  | `develop`, `release`, `master`, `main` | `opened`, `synchronize`, `reopened`, `ready_for_review`                                                                                                 |
| `workflow_call` | —                                      | reusable from other workflows (requires `TF_API_TOKEN`, optional `INFRACOST_API_KEY`)                                                                   |

---

### 🏗️ CI/CD Pipeline Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────────-┐
│                            GitHub Events (Triggers)                                          │
│  push (feature branches only, excl. README.md)  │  pull_request (develop/release/master/main)│
│                         │                       │              │                             │
│                         └───────────────────────┴──────────────┘                             │
│                                        │                                                     │
└────────────────────────────────────────┼─────────────────────────────────────────────────────┘
                                         │
                                         ▼
                          ╔══════════════════════════╗
                          ║  🛑 guard-direct-push    ║  ── ubuntu-latest ──────────────────────
                          ║  ─────────────────────── ║
                          ║  Layer 1: branches-ignore║
                          ║  in push trigger skips   ║
                          ║  workflow entirely for   ║
                          ║  protected branches      ║
                          ║                          ║
                          ║  Layer 2 (defence-in-    ║
                          ║  depth): if push event   ║
                          ║  ref == main | master |  ║
                          ║  develop | release →     ║
                          ║  exit 1 with ::error::   ║
                          ║  naming github.actor     ║
                          ║  and blocked branch      ║
                          ╚══════════════════════════╝
                                         │  ✅ pass (or skipped for PR/workflow_call)
                                         ▼
                          ╔══════════════════════════╗
                          ║   🪝 pre-commit-hooks    ║  ── ubuntu-latest ──────────────────────
                          ║  ─────────────────────── ║
                          ║  • actions/checkout@v4   ║
                          ║  • setup-python 3.12     ║
                          ║  • hashicorp/setup-tf    ║
                          ║  • setup-tflint v0.61.0  ║
                          ║  • pip: pre-commit +     ║
                          ║         checkov          ║
                          ║  • install Trivy v0.70.0 ║
                          ║  • install Gitleaks      ║
                          ║    v8.27.2               ║
                          ║  • pre-commit run        ║
                          ║    --all-files           ║
                          ╚══════════════════════════╝
                                         │  ✅ pass
                                         ▼
                          ╔══════════════════════════╗
                          ║  📁 check-required-files ║  ── ubuntu-latest ──────────────────────
                          ║  ─────────────────────── ║
                          ║  Asserts these files     ║
                          ║  exist in the repo:      ║
                          ║  • examples/main.tf      ║
                          ║  • examples/variables.tf ║
                          ║  • examples/outputs.tf   ║
                          ║  • examples/README.md    ║
                          ║  • README.md             ║
                          ║  • trivy.yaml            ║
                          ║  • .tflint.hcl           ║
                          ╚══════════════════════════╝
                                         │  ✅ pass
          ┌──────────────┬───────────────┼───────────────┬─────────────────┐
          │              │               │               │                 │
          ▼              ▼               ▼               ▼                 ▼
  ╔═══════════╗  ╔══════════════╗  ╔══════════╗  ╔══════════╗  ╔══════════════════╗
  ║ 💰        ║  ║ 🛡️ checkov-  ║  ║ 🔬 trivy-║  ║ 🧹tflint-║  ║ 🤖 amazonq-       ║
  ║ infracost ║  ║ scan         ║  ║ scan     ║  ║ scan     ║  ║ rules-check      ║
  ║ ───────── ║  ║ ──────────── ║  ║ ──────── ║  ║ ──────── ║  ║ ──────────────── ║
  ║ Infracost ║  ║ checkov-     ║  ║ trivy-   ║  ║ setup-   ║  ║ Verify           ║
  ║ breakdown ║  ║ action       ║  ║ action   ║  ║ tflint   ║  ║ .amazonq/rules/  ║
  ║ → JSON    ║  ║ v12.3092.0   ║  ║ v0.36.0  ║  ║ v0.61.0  ║  ║ vpc-module-      ║
  ║           ║  ║              ║  ║          ║  ║          ║  ║ rules.md exists  ║
  ║ table     ║  ║ framework:   ║  ║ config   ║  ║ tflint   ║  ║                  ║
  ║ output    ║  ║ terraform    ║  ║ scan     ║  ║ --init   ║  ║ Validate TF code ║
  ║           ║  ║              ║  ║          ║  ║ --chdir  ║  ║ against rules:   ║
  ║ PR comment║  ║ skip:        ║  ║ severity:║  ║ --format ║  ║ • no public IP   ║
  ║ (if PR)   ║  ║ CKV_TF_1     ║  ║ CRITICAL ║  ║ =compact ║  ║ • no SNS ARNs    ║
  ║           ║  ║              ║  ║ HIGH     ║  ║          ║  ║ • no vpc=true    ║
  ║ skipped   ║  ║ SARIF output ║  ║ MEDIUM   ║  ║          ║  ║ • required files ║
  ║ if no key ║  ║              ║  ║ LOW      ║  ║          ║  ║ • var desc       ║
  ╚═══════════╝  ╚══════════════╝  ╚══════════╝  ╚══════════╝  ╚══════════════════╝
          │              │               │               │                 │
          └──────────────┴───────────────┼───────────────┴─────────────────┘
                                         │  all ✅ (infracost may be skipped)
                                         ▼
                          ╔══════════════════════════╗
                          ║   📊 scan-results        ║  ── runs: always() ─────────────────────
                          ║  ─────────────────────── ║
                          ║  Aggregates all job      ║
                          ║  results and prints a    ║
                          ║  formatted summary table ║
                          ║  to the runner console   ║
                          ║                          ║
                          ║  Exits 1 (blocks merge)  ║
                          ║  if ANY scan failed      ║
                          ║  (infracost: skipped=ok) ║
                          ╚══════════════════════════╝
                                         │
                    ┌────────────────────┴────────────────────┐
                    │  if: pull_request                        │  if: pull_request closed
                    │                                          │      + merged == true
                    ▼                                          ▼      + base ∈ protected branches
     ╔═════════════════════════════╗         ╔═════════════════════════════╗
     ║  🏗️ terraform-plan (CI)     ║         ║  🚀 terraform-apply (CD)    ║
     ║  ─────────────────────────  ║         ║  ─────────────────────────  ║
     ║  AWS Auth: OIDC role        ║         ║  AWS Auth: OIDC role        ║
     ║  (configure-aws-credentials)║         ║  (configure-aws-credentials)║
     ║  + verify STS identity      ║         ║                             ║
     ║                             ║         ║  • terraform init           ║
     ║  • terraform fmt -check     ║         ║  • terraform apply          ║
     ║  • terraform init           ║         ║    -auto-approve            ║
     ║  • terraform validate       ║         ║    -input=false             ║
     ║  • terraform plan           ║         ║                             ║
     ║    → /tmp/tfplan.txt        ║         ║  working-dir:               ║
     ║                             ║         ║  CONFIG_DIRECTORY (.)       ║
     ║  Post plan output as PR     ║         ╚═════════════════════════════╝
     ║  comment (github-script)    ║
     ║  • fmt / init / validate /  ║
     ║    plan status table        ║
     ║  • collapsible full plan    ║
     ║  • updates existing comment ║
     ║    if already posted        ║
     ║                             ║
     ║  Fail job if init/validate/ ║
     ║  plan failed                ║
     ╚═════════════════════════════╝
```

---

### 📋 Job Dependency Graph

```
guard-direct-push
        │  exits 1 if push targets main | master | develop | release
        │  pass-through for pull_request and workflow_call events
        ▼
pre-commit-hooks
        │
        ▼
check-required-files
        │
        ├──► infracost           (push + PR only; skipped if no INFRACOST_API_KEY)
        ├──► checkov-scan        (Terraform IaC SAST — framework: terraform)
        ├──► trivy-scan          (Terraform misconfig — severity: CRITICAL→UNKNOWN)
        ├──► tflint-scan         (Terraform linting — rules from .tflint.hcl)
        └──► amazonq-rules-check (Amazon Q Developer coding rules enforcement)
                │
                ▼
           scan-results          (always runs — aggregates all results)
                │
                ├──► terraform-plan   (only on: pull_request)
                └──► terraform-apply  (only on: PR closed + merged → protected branch)
```

---

### 🔐 Required Secrets

| Secret              | Used By                             | Purpose                                                      |
| ------------------- | ----------------------------------- | ------------------------------------------------------------ |
| `TF_API_TOKEN`      | `terraform-plan`, `terraform-apply` | Terraform Cloud / HCP Terraform authentication               |
| `INFRACOST_API_KEY` | `infracost`                         | Infracost cloud pricing API (optional — job skips if absent) |
| `AWS_ROLE_ARN`      | `terraform-plan`, `terraform-apply` | IAM role ARN for OIDC authentication                         |
| `ROLE_SESSION_NAME` | `terraform-plan`, `terraform-apply` | AWS STS session name                                         |
| `AWS_REGION`        | `terraform-plan`, `terraform-apply` | Target AWS region                                            |

> AWS authentication uses **OIDC** (`id-token: write`) via `aws-actions/configure-aws-credentials@v4` — no long-lived static keys stored in secrets.

---

### 🛡️ Security & Quality Gates

| Gate                 | Tool                                             |     Blocks merge?      | Condition                    |
| -------------------- | ------------------------------------------------ | :--------------------: | ---------------------------- |
| Direct-push guard    | `branches-ignore` + `guard-direct-push` job      |         ✅ yes          | push to protected branch     |
| Pre-push hooks       | pre-commit + Gitleaks + TFLint + Checkov + Trivy |         ✅ yes          | always                       |
| Required files check | bash assertions                                  |         ✅ yes          | always                       |
| Cost estimate        | Infracost                                        | ✅ yes (if key present) | push + PR                    |
| IaC SAST             | Checkov `v12.3092.0`                             |         ✅ yes          | always                       |
| Misconfig scan       | Trivy `v0.36.0`                                  |         ✅ yes          | always                       |
| Linting              | TFLint `v0.61.0`                                 |         ✅ yes          | always                       |
| Amazon Q rules       | custom bash checks                               |         ✅ yes          | always                       |
| Terraform plan       | Terraform CLI                                    |         ✅ yes          | PR only                      |
| Terraform apply      | Terraform CLI                                    |    N/A (post-merge)    | merged PR → protected branch |

---

### 🌿 Branch Strategy

```
main / master / develop / release
    ▲
    │  direct push ──► ❌ BLOCKED
    │                  Layer 1: branches-ignore silently skips the workflow
    │                  Layer 2: guard-direct-push exits 1 with ::error::
    │                           naming github.actor + blocked branch
    │
feature/* ──push──► guard-direct-push ✅ → pre-commit-hooks → ... → scan-results
    │
    └──PR──► develop / release / master / main
                │
                │   [scan-results ✅]
                │
                ├──► terraform-plan runs → PR comment with fmt/init/validate/plan table
                │
                └── merge ──► terraform-apply runs (auto-approve)
```

> **Note:** For complete enforcement, enable GitHub Branch Protection Rules for all four protected branches (`develop`, `release`, `master`, `main`), requiring PRs and status checks. The `guard-direct-push` job is defence-in-depth, not a substitute for repository-level branch protection.
>
> **How to enable GitHub Branch Protection Rules:**
>
> 1. Go to your repository on GitHub
> 2. Click **Settings** (top navigation bar, requires admin access)
> 3. In the left sidebar, under **Code and automation**, click **Branches**
> 4. Under **Branch protection rules**, click **Add branch protection rule**
> 5. In **Branch name pattern**, enter each protected branch name (e.g. `main`, `master`, `develop`, `release`) — repeat for each
> 6. Enable the following settings for each branch:
>    - ✅ **Require a pull request before merging**
>      - ✅ Require approvals → set minimum to `1` (or more for stricter control)
>      - ✅ Dismiss stale pull request approvals when new commits are pushed
>      - ✅ Require review from Code Owners (if a `CODEOWNERS` file is present)
>    - ✅ **Require status checks to pass before merging**
>      - ✅ Require branches to be up to date before merging
>      - 🔍 In the search box, add each required status check by job name: `pre-commit-hooks`, `check-required-files`, `checkov-scan`, `trivy-scan`, `tflint-scan`, `amazonq-rules-check`, `scan-results`, `terraform-plan`
>    - ✅ **Require conversation resolution before merging**
>    - ✅ **Do not allow bypassing the above settings** (prevents admins from force-merging)
>    - ✅ **Restrict who can push to matching branches** → add only trusted users/teams
> 7. Click **Create** (or **Save changes** if editing an existing rule)
>
> 💡 **Tip:** For `main` and `master`, also enable:
> - ✅ **Require linear history** — enforces a clean, rebase-only merge strategy
> - ✅ **Lock branch** — makes the branch read-only; all changes must go through a PR

---



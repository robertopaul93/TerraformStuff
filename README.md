# Terraform AWS Test Environment

This repository contains a modular Terraform configuration for an AWS "test" environment, plus CI workflows and lightweight Terraform tests. It is designed to be secure by default, easy to iterate on locally, and safe to run in CI without real cloud access.

## Architecture Overview

The Terraform code lives under `Terraform_AWS` and is split into:

- **Environments** – concrete stacks that wire modules together
  - `Environments/Test/` – entry point for the test environment
    - Composes all core modules (networking, ALB, compute, storage, monitoring)
    - Configures the AWS provider and environment-specific variables

- **Modules** – reusable building blocks
  - `Modules/ALB/` – Application Load Balancer
    - Internet-facing ALB with HTTPS listener
    - Security group with restricted ingress and descriptive rules
  - `Modules/Compute/` – ECS Fargate compute
    - ECS cluster, task definition, and service
    - Security group for the service and target group integration with the ALB
  - `Modules/Networking/` – VPC networking
    - VPC, public and private subnets, NAT, and IGW
    - Outputs VPC ID, subnet IDs, and CIDR block
  - `Modules/Storage/` – Data layer
    - Aurora PostgreSQL cluster and instances
    - KMS key and alias for encryption
    - DynamoDB table with encryption and PITR
    - AWS Backup vault/plan/selection for Aurora
  - `Modules/Monitoring/` – CloudWatch alarms
    - ECS CPU/memory alarms
    - ALB 5xx/latency alarms
    - Aurora CPU/storage and DynamoDB throttling alarms


## Setup and Deployment

### Prerequisites

- Terraform `>= 1.7`
- AWS provider `~> 6.0` (handled by the config)
- An AWS account and credentials **if** you intend to run real `terraform plan/apply`
- A value for the Aurora master password, provided securely (no hard-coding)

### Initial Setup

From the repository root:

1. Change into the test environment directory:
   - `cd Terraform_AWS/Environments/Test`

2. Configure the Aurora master password for local runs, either:
   - Via environment variable (recommended for local use):
     - PowerShell: `$env:TF_VAR_aurora_master_password = 'your-strong-password'`
   - Or via a local `terraform.tfvars` file (not committed):
     - `aurora_master_password = "your-strong-password"`

3. Initialize Terraform (local backend):
   - `terraform init -backend=false`

### Planning and Applying

- Plan (using the configured password):
  - `terraform plan -lock=false -input=false -refresh=false -no-color -out=tfplan`

- Apply (this will create real AWS resources):
  - `terraform apply tfplan`

The AWS provider in `Environments/Test/providers.tf` is tuned for CI and offline testing (skip validations, dummy credentials), so before using this configuration in a real AWS account you should tighten the provider settings and switch to real credentials.

## Testing

There are two main layers of testing: CLI tooling and Terraform-native tests, plus CI automation.

### Local CLI and Linting

From the repository root (`Terraform_AWS`):

- Format check:
  - `terraform fmt -check -recursive`
- Linting with TFLint (after installing tflint):
  - `tflint --recursive`

From `Terraform_AWS/Environments/Test`:

- Validate the configuration:
  - `terraform validate`

### Terraform Tests (plan-only)

Terraform 1.7 test files live in `Terraform_AWS/Environments/Test`:

- `basic_plan.tftest.hcl`
  - Asserts that:
    - The VPC CIDR is `172.16.0.0/16`
    - The Aurora cluster backup retention period is at least 7 days
- `alb_compute_monitoring.tftest.hcl`
  - Asserts that:
    - ECS cluster and service names follow the expected naming pattern
    - The monitoring module is wired to the same ECS cluster and service identifiers

These tests use:

- `command = plan` to avoid creating real infrastructure
- A test-only AWS provider override with dummy credentials and validation skips
- `plan_options { refresh = false }` to avoid hitting real AWS APIs
- A toggle to disable DynamoDB in tests so no AWS calls are made for that table

Run all tests from `Terraform_AWS/Environments/Test`:

- `terraform test`

### GitHub Actions CI

The repository includes several workflows under `.github/workflows`:

- `terraform-ci.yml`
  - **checkov** – Static security scanning of the Terraform code
  - **lint** – Runs `terraform fmt -check`, `terraform init -backend=false`, `terraform validate`, and `tflint --recursive`
  - **plan-test** – Runs an offline-friendly `terraform plan` in the test environment (non-blocking)
  - **terraform-test** – Runs `terraform test` in the test environment after `terraform init`


Secrets such as `TF_AURORA_MASTER_PASSWORD` are used in CI for sensitive values.

## Design Decisions and Trade-offs

- **Modular structure**
  - Each concern (ALB, compute, networking, storage, monitoring) is isolated in its own module for reusability and clarity.
  - The `Environments/Test` folder composes modules into a concrete environment.

- **Test-friendly AWS provider configuration**
  - In the test environment, the AWS provider is configured with dummy static credentials and `skip_*` flags.
  - This allows `terraform plan` and `terraform test` to run in CI and locally without real AWS credentials, at the cost of not validating against a live account.

- **Terraform tests over heavy integration tests**
  - `terraform test` with `command = plan` is used as a lightweight, offline way to assert on configuration and wiring.
  - This avoids spinning up real infrastructure for tests, but means certain runtime behaviours (e.g., connectivity, IAM permissions) are not exercised.

- **Security and resilience in storage**
  - Aurora uses KMS encryption, deletion protection, log exports, IAM database authentication, and AWS Backup integration.
  - DynamoDB uses encryption, PITR, and configurable billing/attributes.
  - These choices improve data safety at the cost of additional IAM and resource complexity.

- **CI as advisor, not gatekeeper (for now)**
  - Many CI jobs (lint, plan-test, terraform-test) are configured with `continue-on-error: true`.
  - This surfaces issues without blocking merges, which is friendly during early development but can be tightened later.

- **Availability zones and NAT strategy**
  - The networking module currently uses two availability zones by default; this keeps costs and complexity lower but could be expanded to three AZs for additional resiliency.
  - NAT gateways are enabled with one NAT gateway per public subnet (per AZ) instead of a single shared NAT gateway, trading higher cost for better AZ isolation.



## Known Limitations and Areas for Improvement

- **Test provider configuration is not production-ready**
  - The AWS provider in the test environment uses dummy credentials and skips several validations.
  - Before using this configuration in a real or production environment, you should:
    - Remove dummy credentials
    - Re-enable strict provider validation
    - Configure proper credentials (e.g., via IAM roles or OIDC in CI)

- **Local backend only**
  - No remote backend (e.g., S3 + DynamoDB lock) is configured.
  - For team use or non-test environments, adding a remote backend is strongly recommended.

- **Partial test coverage**
  - Terraform tests currently cover key wiring and some critical parameters (VPC CIDR, backup retention, ECS/monitoring linkage).
  - They do not fully validate all alarm thresholds, IAM policies, or every Checkov rule.
  - Additional `.tftest.hcl` files could be added per module for deeper coverage.

- **AWS account assumptions**
  - Some resources assume a typical AWS account setup (e.g., availability zones, IAM managed policies).
  - Running in a more restricted or custom environment may require adjustments.

- **Parameterization for multiple environments**
  - Some settings (for example, autoscaling thresholds for ECS, alarm thresholds, and other tuning knobs) are currently hard-coded or only partially exposed as variables.
  - As additional environments (staging, prod) are added, more of these could be promoted to module inputs so each environment can tune capacity and alerting independently.
 
- **VPC endpoint usage**
  - Many AWS services in this environment currently access the internet via NAT gateways where VPC endpoints could be used instead.
  - Expanding the use of gateway and interface VPC endpoints (for services that support them) would reduce NAT traffic, tighten egress paths, and improve overall network security.

  

## If There Was More Time / Future Work

- **Serverless processing with Lambda and DynamoDB**
  - Finish the Lambda-based serverless processing flow, including event sources, IAM permissions, and error handling, and wire it to persist results into the existing DynamoDB table in the Storage module.

- **Moto-based testing harness**
  - Complete the Python testing harness that uses Moto to mock AWS services and exercise higher-level behaviours (e.g., Lambda + DynamoDB flows) beyond what `terraform test` can cover, and integrate it into the CI pipeline.

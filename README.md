
## Prerequisites

- Terraform >= 1.10
- AWS credentials with permissions to create the resources
- An **existing VPC** whose CIDR matches the subnet CIDRs you provide
- Docker image compatible with the task definition and port 80 (or change `container_port`)

> Important: If you use the AWS default VPC, it already has an Internet Gateway. AWS permits only one IGW attached to a VPC. In that situation, either detach/reuse the existing IGW or modify the module to reference it rather than creating a second one. This behavior comes from the supplied CloudFormation design and should be checked before apply.

## Step 1 - Create Terraform remote-state bucket

```bash
cd terraform/bootstrap
terraform init
terraform apply \
  -var='aws_region=eu-west-1' \
  -var='environment_name=dev' \
  -var='state_bucket_name=YOUR-UNIQUE-BUCKET-NAME'
```

Copy the returned bucket name into `environments/dev/backend.hcl`.

## Step 2 - Configure dev variables

```bash
cd ../environments/dev
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
```

Update at minimum:

```hcl
vpc_id      = "vpc-..."
db_password = "..."
```

For better secret handling, remove the password from `terraform.tfvars` and export it:

```bash
export TF_VAR_db_password='your-strong-password'
```

## Step 3 - Initialize

```bash
terraform init -backend-config=backend.hcl
```

## Step 4 - Validate and plan

```bash
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
```

Review the plan carefully, especially the VPC ID, CIDRs, route tables, NACL associations, NAT gateways and RDS cost.

## Step 5 - Apply

```bash
terraform apply tfplan
```

## Step 6 - Push application image

Terraform outputs the ECR repository URL:

```bash
terraform output -raw ecr_repository_url
```

Authenticate Docker to ECR and push the image using the tag configured in `image_tag` (default `latest`). The ECS service will only become healthy after a valid image exists and the application listens on the configured container port.

## Step 7 - Verify

```bash
terraform output service_url
terraform output ecs_cluster_name
terraform output ecs_service_name
```

Then verify:

- ALB target group reports a healthy target.
- ECS task reaches `RUNNING` state.
- CloudWatch log group receives container logs.
- The application responds through the ALB URL.
- Aurora is reachable only from the ECS security group on TCP/3306.

## Step 8 - Destroy after the assessment

NAT gateways and Aurora can incur noticeable cost. Destroy the dev environment when finished:

```bash
terraform destroy
```

Then remove the remote-state bootstrap only after the dev state is no longer needed.

## Interview explanation

A strong explanation is: "I converted the supplied stack with near one-to-one resource mapping, but I did not preserve obsolete or unsafe behavior blindly. I migrated Aurora Serverless v1 to v2, removed a hard-coded DB password, tightened ALB-to-ECS ingress, fixed the NACL/NAT contradiction, and added ECR/Container Insights because the supplied templates referenced an image repository and the assignment requires production-minded operability."

## CI/CD Pipeline

## CI/CD Pipeline

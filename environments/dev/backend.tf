terraform {
  backend "s3" {
    # Supply bucket/region at terraform init using backend.hcl.
    key          = "dev/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}

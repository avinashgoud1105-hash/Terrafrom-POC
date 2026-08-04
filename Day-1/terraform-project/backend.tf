terraform {
  backend "s3" {
    bucket       = "amzn-s3-avinash-bucket-2026"
    key          = "dev/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true

    # Terraform v1.10+ lockfile support
    use_lockfile = true
  }
}

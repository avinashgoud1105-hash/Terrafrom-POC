terraform {
  backend "s3" {
    bucket       = "avinash-terraform-state-2026"
    key          = "ec2/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
    encrypt      = true
  }
}

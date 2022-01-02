provider "aws" {
    region = var.region[terraform.workspace]
}


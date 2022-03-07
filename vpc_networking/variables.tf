variable  region {
    default = "ap-south-1"
}

variable vpc_cidr_block {}
variable public_subnet_1 {}
variable public_subnet_2 {}
variable public_subnet_3 {}
variable private_subnet_1 {}
variable private_subnet_2 {}
variable private_subnet_3 {}
variable eip_association_address {}
variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "testlab.pem"
}


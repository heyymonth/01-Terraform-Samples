module "vpc_networking" {
    source = "./vpc_networking"
    vpc_cidr_block = var.vpc_cidr_block
    public_subnet_1 = var.public_subnet_1
    public_subnet_2 = var.public_subnet_2
    public_subnet_3 = var.public_subnet_3
    private_subnet_1 = var.private_subnet_1
    private_subnet_2 = var.private_subnet_2
    private_subnet_3 = var.private_subnet_3
    eip_association_address = var.eip_association_address
    ec2_instance_type = var.instance_type
    ec2_keypair = var.ec2_keypair
}
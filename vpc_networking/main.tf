provider "aws" {
    region = var.region
}

resource aws_vpc "module_vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true         #only for publicly accessible ec2 instances

    tags = {
      "Name" = "Testlab-VPC"
    }
}

resource "aws_subnet" "module_public_subnet_1" {
    cidr_block = var.public_subnet_1
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}a"

    tags = {
        Name = "Public Subnet A"
    }
}

resource "aws_subnet" "module_public_subnet_2" {
    cidr_block = var.public_subnet_2
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}b"

    tags = {
        Name = "Public Subnet B"
    }
}

resource "aws_subnet" "module_public_subnet_3" {
    cidr_block = var.public_subnet_3
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}c"

    tags = {
        Name = "Public Subnet C"
    }
}

resource "aws_subnet" "module_private_subnet_1" {
    cidr_block = var.private_subnet_1
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}a"

    tags = {
        Name = "Public Subnet A"
    }
}

resource "aws_subnet" "module_private_subnet_2" {
    cidr_block = var.private_subnet_2
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}b"

    tags = {
        Name = "Public Subnet B"
    }
}

resource "aws_subnet" "module_private_subnet_3" {
    cidr_block = var.private_subnet_3
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}c"

    tags = {
        Name = "Public Subnet C"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.module_vpc.id
    tags = {
        Name="Public Route Table"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.module_vpc.id
    tags = {
        Name="Private Route Table"
    }
}

resource "aws_route_table_association" "public_subnet_1_association" {
    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.module_public_subnet_1
}

resource "aws_route_table_association" "public_subnet_2_association" {
    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.module_public_subnet_2.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.module_public_subnet_3.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
    route_table_id = aws_route_table.private_route_table.id
    subnet_id = aws_subnet.module_private_subnet_1.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
    route_table_id = aws_route_table.private_route_table.id
    subnet_id = aws_subnet.module_private_subnet_1.id
}

resource "aws_route_table_association" "private_subnet_3_association" {
    route_table_id = aws_route_table.private_route_table.id
    subnet_id = aws_subnet.module_private_subnet_3.id
}

# Creating an Elastic IP for NAT Gateway
resource "aws_eip" "elastic_ip_for_nat_gw" {
    vpc = true
    associate_with_private_ip = var.eip_association_address

    tags = {
      "Name" = "Prod-EIP"
    }
}

# Creating a NAT Gateway and Adding to the Route Table
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.elastic_ip_for_nat_gw.id
    subnet_id = aws_subnet.module_public_subnet_1.id

    tags = {
      "Name" = "Prod-NAT-GW"
    }
}

resource "aws_route" "nat_gateway_route" {
    route_table_id = aws_route_table.private_route_table.id
    nat_gateway_id = aws_nat_gateway.nat_gw.id
    destination_cidr_block = "0.0.0.0/0"                        #Without the cidr block in the route table defined as a rule, you cannot really use the definition that you made in the route table. 
                                                                #So in this case, we want to allow any traffic coming and going through the NAT gateway in our route table. So to achieve that, we have to use the zero cidr block.

}

# Creating an Internet GW and Adding to the Route Table

resource "aws_internet_gateway" "internet_gw" {
    vpc_id = aws_vpc.module_vpc.id

    tags {
        Name = "Prod-IGW"
    }
}

resource "aws_route" "igw_route" {
    route_table_id = aws_route_table.public_route_table.id
    gateway_id = aws_internet_gateway.internet_gw.id
    destination_cidr_block = "0.0.0.0/0"
}

## Implementing an EC2 Instance in public subnet

data "aws_ami" "Ubuntu_latest" {
    owners = [ "099720109477" ]
    most_recent = true

    filter {
        name = "virutalization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "ec2-instance" {
    ami = data.aws_ami.Ubuntu_latest.id
    instance_type = var.instance_type
    key_name = var.key_name
    security_groups = [aws_security_group.ec2-security-group.id]
    subnet_id = aws_subnet.module_public_subnet_1.id

    # user_data = ""
}

resource "aws_security_group" "ec2-security-group" {
    name = "EC2-instance-SG"
    vpc_id = aws_vpc.module_vpc.id
    
    ingress = {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "incoming traffic"
      from_port = 0
      protocol = "-1"
      to_port = 0
    } 
   
    egress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "outgoing traffic"
      from_port = 0
      protocol = "-1"
      to_port = 0
    } 
}
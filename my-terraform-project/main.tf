provider "aws" {
  region = "ap-south-1"   # Change if needed
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

# Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Route Table
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

# Security Group
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "my-sg"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # later restrict to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair (use existing key or import your own)
resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")   # update path if needed
}

# Jump Server
resource "aws_instance" "jump" {
  ami           = "ami-02d26659fd82cf299" # Amazon Linux 2 us-east-1
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.my_subnet.id
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "Jump-Server"
  }
}

# 3 EC2 Instances
resource "aws_instance" "nodes" {
  count         = 3
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.my_subnet.id
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "Node-${count.index + 1}"
  }
}

# Outputs
output "jump_public_ip" {
  value = aws_instance.jump.public_ip
}

output "node_private_ips" {
  value = [for n in aws_instance.nodes : n.private_ip]
}

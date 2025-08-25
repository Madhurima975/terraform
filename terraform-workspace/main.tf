provider "aws" {
  region = "us-east-1"
}

variable "ami" {
  description = "value"
}

variable "instance_type" {
  description = "value"
  type = map(string)

  default = {
    "dev" = "t2.micro"
    "stage" = "t3.medium"
    "prod" = "t2.micro"
  }
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}




module "ec2_instance" {
  source = "./modules/ec2_instance"
  ami = var.ami
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
  subnet_id         = var.subnet_id
  
}

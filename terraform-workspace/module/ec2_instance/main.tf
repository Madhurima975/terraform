
variable "ami" {
  description = "This is AMI for the instance"
}

variable "instance_type" {
  description = "This is the instance type, for example: t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}



resource "aws_instance" "example" {
    ami = var.ami
    instance_type = var.instance_type
    subnet_id     = var.subnet_id   # required because no default VPC


}

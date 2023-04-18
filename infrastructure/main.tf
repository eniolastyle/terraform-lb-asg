data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "template_file" "nginx_data_script" {
  template = file("./user-data.tpl")
  vars = {
    server = "nginx"
  }
}

data "template_file" "apache_data_script" {
  template = file("./user-data.tpl")
  vars = {
    server = "apache2"
  }
}




resource "aws_key_pair" "ec2-server" {
  key_name   = var.key_name
  public_key = var.public_key
}


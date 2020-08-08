provider "aws" {
  profile = "default"
  region  = var.aws_region
}

resource "aws_vpc" "tf_wizard_vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name    = "tf_wizard_vpc"
    Project = "terra-scovery"
  }
}

resource "aws_internet_gateway" "tf_wizard_gw" {
  vpc_id = aws_vpc.tf_wizard_vpc.id

  tags = {
    Name    = "tf_wizard_gw"
    Project = "terra-scovery"
  }
}

resource "aws_route_table" "tf_wizard_route_table" {
  vpc_id = aws_vpc.tf_wizard_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_wizard_gw.id
  }

  tags = {
    Name    = "tf_wizard_route_table"
    Project = "terra-scovery"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.tf_wizard_subnet_1.id #TODO: transition from '1' to 'a|b|c'
  route_table_id = aws_route_table.tf_wizard_route_table.id
}

resource "aws_subnet" "tf_wizard_subnet_1" { #TODO: transition from '1' to 'a|b|c'
  vpc_id     = aws_vpc.tf_wizard_vpc.id 
  cidr_block = "192.168.1.0/24"

  tags = {
    Name    = "tf_wizard_subnet_1"
    Project = "terra-scovery"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "allow_ssh"
    Project = "terra-scovery"
  }

  vpc_id = aws_vpc.tf_wizard_vpc.id
}

resource "aws_instance" "tf_wizard_instance" {
  key_name      = var.aws_keypair_name
  ami           = "ami-07c8bc5c1ce9598c3"
  instance_type = "t2.micro"
  associate_public_ip_address  = true

  subnet_id = aws_subnet.tf_wizard_subnet_1.id # TODO Transition from '1' to 'a|b|c'ter

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
}
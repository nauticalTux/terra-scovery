provider "aws" {
  profile = "default"
  region  = var.aws_region
}

resource "aws_instance" "terra-scovery-instance" {
  key_name      = var.aws_keypair_name
  ami           = "ami-07c8bc5c1ce9598c3"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.aws_private_key)
    host        = self.public_ip
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
    Name = "allow_ssh"
  }
}





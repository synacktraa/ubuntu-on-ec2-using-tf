terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC and networking
resource "aws_vpc" "ubuntu_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ubuntu-vpc"
  }
}

resource "aws_internet_gateway" "ubuntu_igw" {
  vpc_id = aws_vpc.ubuntu_vpc.id

  tags = {
    Name = "ubuntu-igw"
  }
}

resource "aws_subnet" "ubuntu_subnet" {
  vpc_id                  = aws_vpc.ubuntu_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "ubuntu-subnet"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_route_table" "ubuntu_rt" {
  vpc_id = aws_vpc.ubuntu_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ubuntu_igw.id
  }

  tags = {
    Name = "ubuntu-rt"
  }
}

resource "aws_route_table_association" "ubuntu_rta" {
  subnet_id      = aws_subnet.ubuntu_subnet.id
  route_table_id = aws_route_table.ubuntu_rt.id
}

# Security Group
resource "aws_security_group" "ubuntu_sg" {
  name        = "ubuntu-security-group"
  description = "Security group for Ubuntu server"
  vpc_id      = aws_vpc.ubuntu_vpc.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ubuntu-sg"
  }
}

# EC2 Instance
resource "aws_key_pair" "generated" {
  key_name   = "ec2-ubuntu"
  public_key = file("${path.module}/ec2-ubuntu.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "ubuntu_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.generated.key_name
  vpc_security_group_ids      = [aws_security_group.ubuntu_sg.id]
  subnet_id                   = aws_subnet.ubuntu_subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
  }

  tags = {
    Name = "ubuntu-server"
  }
}
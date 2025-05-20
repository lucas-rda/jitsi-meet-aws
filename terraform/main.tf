provider "aws" {
  region = var.region
}

# VPC for network isolation
resource "aws_vpc" "jitsi_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = merge(var.tags, {
    Name = "jitsi-vpc"
  })
}

# Public subnet where our EC2 instance will run
resource "aws_subnet" "jitsi_subnet" {
  vpc_id                  = aws_vpc.jitsi_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  
  tags = merge(var.tags, {
    Name = "jitsi-subnet"
  })
}

# Internet Gateway to allow internet access
resource "aws_internet_gateway" "jitsi_igw" {
  vpc_id = aws_vpc.jitsi_vpc.id
  
  tags = merge(var.tags, {
    Name = "jitsi-igw"
  })
}

# Route table for public subnet
resource "aws_route_table" "jitsi_rt" {
  vpc_id = aws_vpc.jitsi_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jitsi_igw.id
  }
  
  tags = merge(var.tags, {
    Name = "jitsi-rt"
  })
}

# Associate route table with subnet
resource "aws_route_table_association" "jitsi_rta" {
  subnet_id      = aws_subnet.jitsi_subnet.id
  route_table_id = aws_route_table.jitsi_rt.id
}

# Create an SSH key pair using the provided public key
resource "aws_key_pair" "jitsi_key" {
  key_name   = "jitsi-key"
  public_key = var.ssh_public_key
  
  tags = merge(var.tags, {
    Name = "jitsi-key"
  })
}

# Create terraform.tfvars.example as a template for users
resource "local_file" "tfvars_example" {
  content  = <<-EOT
    # AWS Region to deploy resources
    region = "us-east-1"
    
    # SSH public key for EC2 instance access
    ssh_public_key = "ssh-rsa YOUR_PUBLIC_KEY_HERE"
    
    # IP CIDR block allowed to SSH into the instance
    allowed_ssh_cidr = "YOUR_IP_ADDRESS/32"
    
    # Domain configuration
    domain_name = "example.com"
    subdomain = "meet"
    hosted_zone_id = "YOUR_ROUTE53_ZONE_ID"
  EOT
  filename = "${path.module}/terraform.tfvars.example"
}

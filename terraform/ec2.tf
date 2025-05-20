# Elastic IP for the Jitsi server
resource "aws_eip" "jitsi_eip" {
  domain = "vpc"
  
  tags = merge(var.tags, {
    Name = "jitsi-eip"
  })
}

# EC2 instance for Jitsi Meet
resource "aws_instance" "jitsi_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.jitsi_key.key_name
  subnet_id              = aws_subnet.jitsi_subnet.id
  vpc_security_group_ids = [aws_security_group.jitsi_sg.id]
  
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }
  
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get upgrade -y
    hostnamectl set-hostname jitsi-server
    echo "${aws_eip.jitsi_eip.public_ip} ${var.subdomain}.${var.domain_name}" >> /etc/hosts
    EOF
  
  tags = merge(var.tags, {
    Name = "jitsi-server"
  })
}

# Associate Elastic IP with EC2 instance
resource "aws_eip_association" "jitsi_eip_assoc" {
  instance_id   = aws_instance.jitsi_server.id
  allocation_id = aws_eip.jitsi_eip.id
}

# Generate a local inventory file for Ansible
resource "local_file" "ansible_inventory" {
  content  = <<-EOT
    [jitsi]
    ${aws_eip.jitsi_eip.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa domain=${var.subdomain}.${var.domain_name}
    
    [jitsi:vars]
    ansible_python_interpreter=/usr/bin/python3
  EOT
  filename = "${path.module}/../provision/inventory.ini"
}

# Output the Jitsi Meet server information
output "jitsi_server_ip" {
  description = "Public IP address of the Jitsi Meet server"
  value       = aws_eip.jitsi_eip.public_ip
}

output "jitsi_server_dns" {
  description = "DNS name of the Jitsi Meet server"
  value       = "${var.subdomain}.${var.domain_name}"
}

output "ssh_command" {
  description = "SSH command to connect to the Jitsi Meet server"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.jitsi_eip.public_ip}"
}

output "jitsi_url" {
  description = "URL to access Jitsi Meet"
  value       = "https://${var.subdomain}.${var.domain_name}"
}

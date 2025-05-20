# Security Group for Jitsi Meet server
resource "aws_security_group" "jitsi_sg" {
  name        = "jitsi-security-group"
  description = "Allow traffic for Jitsi Meet server"
  vpc_id      = aws_vpc.jitsi_vpc.id

  # SSH access - restricted to specified CIDR
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
    description = "SSH access"
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # UDP for WebRTC - main video port
  ingress {
    from_port   = 10000
    to_port     = 10000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "WebRTC main video port"
  }
  
  # TCP for XMPP server
  ingress {
    from_port   = 5222
    to_port     = 5222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "XMPP server"
  }
  
  # TCP for BOSH/WebSocket
  ingress {
    from_port   = 5280
    to_port     = 5280
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "BOSH/WebSocket"
  }
  
  # UDP range for Jitsi Videobridge (for larger installations)
  ingress {
    from_port   = 10000
    to_port     = 20000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jitsi Videobridge UDP range"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "jitsi-sg"
  })
}

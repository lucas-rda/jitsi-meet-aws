variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "ami_id" {
  description = "AMI ID for the Jitsi Meet server (Ubuntu 22.04 LTS recommended)"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 22.04 in us-east-1, update for different regions
}

variable "instance_type" {
  description = "EC2 instance type for Jitsi Meet server"
  type        = string
  default     = "t3.medium" # Recommended for small to medium Jitsi deployments
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 30
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 instance access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the Jitsi server"
  type        = string
  default     = "0.0.0.0/0" # Consider restricting to your IP for production
}

variable "domain_name" {
  description = "The domain name for Jitsi Meet"
  type        = string
  default     = "example.com"
}

variable "subdomain" {
  description = "Subdomain for Jitsi Meet (will be prepended to domain_name)"
  type        = string
  default     = "meet"
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID for the domain"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "jitsi-meet"
    Environment = "demo"
    Terraform   = "true"
  }
}

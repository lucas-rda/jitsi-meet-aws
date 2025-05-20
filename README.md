# Jitsi Meet on AWS with Terraform and Ansible

This project automates the deployment of a secure, production-ready [Jitsi Meet](https://jitsi.org/jitsi-meet/) video conferencing server on AWS using Terraform for infrastructure provisioning and Ansible for application configuration.

## Features

- **Fully Automated Deployment**: Infrastructure and application setup in a few commands
- **Secure by Default**: Proper security groups, restricted SSH access, HTTPS with Let's Encrypt
- **Scalable Infrastructure**: Easily configurable for different meeting sizes
- **DNS Configuration**: Automatic Route53 DNS record creation
- **Minimal Maintenance**: Simple to update and maintain

## Architecture

```
┌───────────────────┐          ┌───────────────────────────────────┐
│                   │          │                                   │
│  Route53 DNS      │───────▶  │  EC2 Instance (Ubuntu 22.04)      │
│  meet.example.com │          │                                   │
│                   │          │  - Jitsi Meet Server              │
└───────────────────┘          │  - Nginx with Let's Encrypt       │
                               │  - Prosody XMPP Server            │
                               │  - Jitsi Videobridge              │
                               │                                   │
                               └───────────────────────────────────┘
                                            ▲
                                            │
                               ┌────────────┴────────────┐
                               │                         │
                               │  Security Group         │
                               │  - SSH (22): Restricted │
                               │  - HTTP (80): Public    │
                               │  - HTTPS (443): Public  │
                               │  - UDP (10000): Public  │
                               │                         │
                               └─────────────────────────┘
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0+)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (v2.9+)
- AWS Account with admin permissions
- Registered domain with Route53 hosted zone
- SSH keypair for server access

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/lucas-rda/jitsi-meet-aws.git
cd jitsi-on-aws
```

### 2. Configure terraform.tfvars file

After running `terraform init`, you'll find a `terraform.tfvars.example` file automatically created in the project directory. Copy it to create your configuration:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit the `terraform.tfvars` file with your specific values:

```
# AWS Region to deploy resources
region = "us-east-1"

# SSH public key for EC2 instance access (required)
ssh_public_key = "ssh-rsa YOUR_PUBLIC_KEY_HERE"

# IP CIDR block allowed to SSH into the instance (for security)
allowed_ssh_cidr = "YOUR_IP_ADDRESS/32"

# Domain configuration (required)
domain_name = "example.com"
subdomain = "meet"
hosted_zone_id = "YOUR_ROUTE53_ZONE_ID"
```

### 3. Deploy infrastructure with Terraform

```bash
terraform init
terraform plan
terraform apply
```

### 4. Deploy Jitsi Meet with Ansible

After the infrastructure is provisioned, Terraform will automatically generate an Ansible inventory file at `../provision/inventory.ini` with the correct server IP, user, and domain name.

```bash
cd ../provision
ansible-playbook -i inventory.ini playbook.yml
```

Note: The `inventory.ini` file is generated dynamically by Terraform based on your deployment, so you don't need to create or edit it manually.

## Accessing Jitsi Meet

Once deployment is complete, you can access your Jitsi Meet installation at:

```
https://meet.example.com
```

(Replace `meet.example.com` with your configured domain)

##  Customization

### Scaling for larger meetings

For larger meetings or higher load, consider:

1. Adjust the EC2 instance type in `variables.tf`:
   ```
   variable "instance_type" {
     default = "t3.large"  # Or an even larger instance type
   }
   ```

2. Increase the root volume size:
   ```
   variable "root_volume_size" {
     default = 50  # GB
   }
   ```

### Security hardening

For increased security:

1. Restrict SSH access to your IP only in `terraform.tfvars`:
   ```
   allowed_ssh_cidr = "YOUR_IP_ADDRESS/32"
   ```

2. Consider implementing additional security measures in the Ansible playbook.

##  Cleanup

To destroy all created resources:

```bash
cd terraform
terraform destroy
```

## Security Considerations

- The server is configured with Let's Encrypt SSL certificates for HTTPS.
- SSH access is restricted to the IP range specified in `allowed_ssh_cidr`.
- Security groups are configured to allow only necessary traffic.
- All communications are encrypted using standard web security practices.

  
## Acknowledgements

- [Jitsi Meet](https://jitsi.org/jitsi-meet/) for their amazing open-source video conferencing platform
- [Terraform](https://www.terraform.io/) for infrastructure as code capabilities
- [Ansible](https://www.ansible.com/) for configuration management

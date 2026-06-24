# Host a Static Website on EC2 from GitHub (Terraform)

This Terraform project provisions an AWS EC2 instance, installs Nginx,
pulls a static website from a GitHub repository, and serves it so you can
access it via the EC2 public IP.

## Flow

Terraform → EC2 → Install Nginx → Pull site from GitHub → Deploy → Access via Public IP

## Files

- versions.tf — Terraform + AWS provider definitions
- variables.tf — Input variables for region, instance type, GitHub repo, etc.
- data.tf — AMI and default VPC lookups
- security_group.tf — Security group opening HTTP(80) and SSH(22)
- main.tf — EC2 instance and user_data wiring
- user_data.sh.tpl — Bootstrap script to install Nginx, clone repo, and deploy
- outputs.tf — Useful outputs (public IP, website URL)
- terraform.tfvars.example — Example variables file to copy and customize
- .gitignore — Ignore Terraform state and secrets

## Prerequisites

1. Terraform >= 1.3
2. AWS credentials configured (`aws configure`) or environment variables:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_DEFAULT_REGION
3. A public GitHub repo containing your static site (must include index.html).

## Usage

1) Configure variables:
   - Copy terraform.tfvars.example to terraform.tfvars
   - Edit terraform.tfvars (set github_repo_url, optionally key_pair_name and ssh_ingress_cidr)

2) Initialize and deploy:
   - terraform init
   - terraform plan
   - terraform apply -auto-approve

3) Open the website:
   - terraform output website_url
   - Paste the URL into your browser (wait ~1–2 minutes for first boot)

## Verification and Troubleshooting

- Check bootstrap log: sudo cat /var/log/user-data.log
- Check Nginx: sudo systemctl status nginx
- SSH (if key_pair_name provided): ssh -i <your-key>.pem ec2-user@<public_ip>

## Clean Up

terraform destroy -auto-approve

## Notes

- This uses the default VPC for simplicity.
- For security, restrict ssh_ingress_cidr to your IP (e.g., 203.0.113.10/32).

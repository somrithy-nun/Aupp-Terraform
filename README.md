# Docker App Deployment Pipeline on AWS EC2

This project provisions an AWS EC2 instance with Terraform, pulls application
code from GitHub, builds a Docker image on the instance, runs the container,
and exposes the app through the instance public IP.

## Flow

GitHub repo -> Terraform -> EC2 -> Install Docker -> Pull code -> Build image -> Run container -> Public IP

## GitHub Actions Pipeline

The workflow in `.github/workflows/deploy.yml` performs the pipeline:

1. Pulls this repository from GitHub.
2. Builds the Docker image from `app/`.
3. Runs Terraform to create/update the EC2 instance.
4. EC2 user data clones the repo, builds the image on the instance, and runs the container.
5. The workflow prints the public URL from `terraform output website_url`.

Required GitHub repository secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Optional GitHub repository variables:

- `AWS_REGION`, default `us-east-1`
- `EC2_KEY_PAIR_NAME`, only if you want SSH access
- `SSH_INGRESS_CIDR`, recommended as your IP with `/32`

## Files

- versions.tf — Terraform + AWS provider definitions
- variables.tf — Input variables for region, instance type, GitHub repo, etc.
- data.tf — AMI and default VPC lookups
- security_group.tf — Security group opening the app port and SSH(22)
- main.tf — EC2 instance and user_data wiring
- user_data.sh.tpl — Bootstrap script to install Docker, clone repo, build, and run the container
- outputs.tf — Useful outputs (public IP, website URL)
- app/ — Example Dockerized Node.js application
- .github/workflows/deploy.yml — GitHub Actions deployment pipeline
- terraform.tfvars.example — Example variables file to copy and customize
- .gitignore — Ignore Terraform state and secrets

## Prerequisites

1. Terraform >= 1.3
2. AWS credentials configured (`aws configure`) or environment variables:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_DEFAULT_REGION
3. A public GitHub repo containing this project, including `app/Dockerfile`.

## Usage

1) Configure variables:
   - Copy terraform.tfvars.example to terraform.tfvars
   - Edit terraform.tfvars
   - Set github_repo_url to the HTTPS URL for the GitHub repo containing this project
   - Set app_subdir to the directory containing the Dockerfile, usually `app`
   - Optionally set key_pair_name and ssh_ingress_cidr

2) Initialize and deploy:
   - terraform init
   - terraform plan
   - terraform apply -auto-approve

3) Open the app:
   - terraform output website_url
   - Paste the URL into your browser (wait ~1–2 minutes for first boot)

## Verification and Troubleshooting

- Check bootstrap log: sudo cat /var/log/user-data.log
- Check Docker: sudo systemctl status docker
- Check container: sudo docker ps
- Check logs: sudo docker logs terraform-docker-app
- SSH (if key_pair_name provided): ssh -i <your-key>.pem ec2-user@<public_ip>

## Clean Up

terraform destroy -auto-approve

## Notes

- This uses the default VPC for simplicity.
- For security, restrict ssh_ingress_cidr to your IP (e.g., 203.0.113.10/32).
- The default app listens on container port 3000 and is mapped to host port 80.

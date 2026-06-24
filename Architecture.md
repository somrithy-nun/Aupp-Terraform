
## Architecture

| Resource              | Purpose                                              |
|-----------------------|------------------------------------------------------|
| `aws_instance.web`    | EC2 instance running the web server                  |
| `aws_security_group`  | Opens ports 80 (HTTP) and 22 (SSH)                   |
| `data.aws_ami`        | Latest Amazon Linux 2023 AMI                         |
| `user_data.sh.tpl`    | Bootstrap script: installs Nginx, clones repo, deploys |

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.3
2. AWS account + credentials configured (`aws configure` or env vars):
   ```bash
   export AWS_ACCESS_KEY_ID="..."
   export AWS_SECRET_ACCESS_KEY="..."
   export AWS_DEFAULT_REGION="us-east-1"
   ```
3. A public GitHub repo containing your static site (must include `index.html`).

## Usage

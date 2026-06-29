
## Architecture

| Resource              | Purpose                                              |
|-----------------------|------------------------------------------------------|
| `aws_instance.web`    | EC2 instance running the Docker container            |
| `aws_security_group`  | Opens the app port, default 80, and SSH              |
| `data.aws_ami`        | Latest Amazon Linux 2023 AMI                         |
| `user_data.sh.tpl`    | Bootstrap script: installs Docker, clones repo, builds, and runs the app |
| `app/`                | Example Dockerized Node.js app                       |

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.3
2. AWS account + credentials configured (`aws configure` or env vars):
   ```bash
   export AWS_ACCESS_KEY_ID="..."
   export AWS_SECRET_ACCESS_KEY="..."
   export AWS_DEFAULT_REGION="us-east-1"
   ```
3. A public GitHub repo containing this project and `app/Dockerfile`.

## Usage

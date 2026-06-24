variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A name prefix used for tagging and naming resources."
  type        = string
  default     = "static-website"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro" # Free-tier eligible
}

variable "key_pair_name" {
  description = "Name of an EXISTING EC2 key pair to enable SSH access. Leave empty to skip SSH key."
  type        = string
  default     = ""
}

variable "github_repo_url" {
  description = "HTTPS clone URL of the GitHub repository that contains the static website."
  type        = string
  # Example: https://github.com/your-username/your-static-site.git
  default     = "https://github.com/cloudacademy/static-website-example.git"
}

variable "github_branch" {
  description = "Branch to pull from the GitHub repository."
  type        = string
  default     = "main"
}

variable "site_subdir" {
  description = "Subdirectory inside the repo that contains index.html. Use '.' if files are at the repo root."
  type        = string
  default     = "."
}

variable "ssh_ingress_cidr" {
  description = "CIDR block allowed to SSH (port 22). Restrict this to your IP for security."
  type        = string
  default     = "0.0.0.0/0"
}

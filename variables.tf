variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A name prefix used for tagging and naming resources."
  type        = string
  default     = "docker-ec2-app"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t2.micro" # Free-tier eligible
}

variable "key_pair_name" {
  description = "Name of an EXISTING EC2 key pair to enable SSH access. Leave empty to skip SSH key."
  type        = string
  default     = "vockey"
}

variable "github_repo_url" {
  description = "HTTPS clone URL of the GitHub repository that contains this Dockerized application."
  type        = string
  default     = "https://github.com/somrithy-nun/app-x-terraform.git"
}

variable "github_branch" {
  description = "Branch to pull from the GitHub repository."
  type        = string
  default     = "main"
}

variable "app_subdir" {
  description = "Subdirectory inside the GitHub repo that contains the Dockerfile."
  type        = string
  default     = "app"
}

variable "docker_image_name" {
  description = "Local Docker image name to build on the EC2 instance."
  type        = string
  default     = "terraform-docker-app"
}

variable "container_name" {
  description = "Name of the Docker container to run on the EC2 instance."
  type        = string
  default     = "terraform-docker-app"
}

variable "container_port" {
  description = "Port exposed by the application inside the Docker container."
  type        = number
  default     = 3000
}

variable "host_port" {
  description = "Public port on the EC2 instance that forwards to the container."
  type        = number
  default     = 80
}

variable "ssh_ingress_cidr" {
  description = "CIDR block allowed to SSH (port 22). Restrict this to your IP for security."
  type        = string
  default     = "0.0.0.0/0"
}

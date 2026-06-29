resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow app HTTP and SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  # HTTP - so the containerized app is reachable from the browser.
  ingress {
    description = "Application HTTP from anywhere"
    from_port   = var.host_port
    to_port     = var.host_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH - for administration/debugging
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  # Allow all outbound (needed to pull from GitHub & install packages)
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

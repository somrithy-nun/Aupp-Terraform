locals {
  # Render the bootstrap script with our variables injected.
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    github_repo_url   = var.github_repo_url
    github_branch     = var.github_branch
    app_subdir        = var.app_subdir
    docker_image_name = var.docker_image_name
    container_name    = var.container_name
    container_port    = var.container_port
    host_port         = var.host_port
  })
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # key_pair_name may be empty; only set it if provided.
  key_name = var.key_pair_name != "" ? var.key_pair_name : null

  # Bootstrap: install Docker, pull from GitHub, build, and run the container.
  user_data                   = local.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-ec2"
    Project = var.project_name
  }
}

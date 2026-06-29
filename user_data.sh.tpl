#!/bin/bash
set -euxo pipefail

# Log everything to a file for easy debugging on the instance.
exec > >(tee /var/log/user-data.log) 2>&1

echo "===== Updating packages ====="
dnf update -y

echo "===== Installing Docker and Git ====="
dnf install -y docker git

echo "===== Enabling and starting Docker ====="
systemctl enable docker
systemctl start docker

echo "===== Cloning GitHub repository ====="
APP_DIR="/opt/app-source"
rm -rf "$APP_DIR"
git clone --branch "${github_branch}" --depth 1 "${github_repo_url}" "$APP_DIR"

echo "===== Building Docker image ====="
BUILD_DIR="$APP_DIR"
if [ ! -f "$BUILD_DIR/Dockerfile" ]; then
  echo "ERROR: Dockerfile not found at $BUILD_DIR/Dockerfile"
  echo "Repo contents:"
  find "$APP_DIR" -maxdepth 3 -type f | sort
  exit 1
fi
docker build -t "${docker_image_name}:latest" "$BUILD_DIR"

echo "===== Starting Docker container ====="
docker rm -f "${container_name}" || true
docker run -d \
  --name "${container_name}" \
  --restart unless-stopped \
  -p ${host_port}:${container_port} \
  "${docker_image_name}:latest"

docker ps --filter "name=${container_name}"

echo "===== Done! Docker app deployed on port ${host_port}. ====="

#!/bin/bash
set -euxo pipefail

# Log everything to a file for easy debugging on the instance
exec > >(tee /var/log/user-data.log) 2>&1

echo "===== Updating packages ====="
dnf update -y

echo "===== Installing Nginx and Git ====="
dnf install -y nginx git

echo "===== Enabling and starting Nginx ====="
systemctl enable nginx
systemctl start nginx

echo "===== Cloning GitHub repository ====="
APP_DIR="/opt/website"
rm -rf "$APP_DIR"
git clone --branch "${github_branch}" --depth 1 "${github_repo_url}" "$APP_DIR"

echo "===== Deploying static files to Nginx web root ====="
WEB_ROOT="/usr/share/nginx/html"
rm -rf "$${WEB_ROOT:?}"/*

# Copy the contents of the chosen subdirectory into the web root
cp -r "$APP_DIR/${site_subdir}/." "$WEB_ROOT/"

# Make sure permissions are correct
chown -R nginx:nginx "$WEB_ROOT"
chmod -R 755 "$WEB_ROOT"

echo "===== Restarting Nginx to serve new content ====="
systemctl restart nginx

echo "===== Done! Website deployed. ====="

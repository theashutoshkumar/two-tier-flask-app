#!/bin/bash

# Exit script if any command fails
set -e

echo "🚀 Starting Docker installation..."

# Update system packages
echo "📦 Updating packages..."
sudo apt-get update -y

# Install required dependencies
echo "🔧 Installing dependencies..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
echo "🔑 Adding Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo "📁 Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update packages again
echo "🔄 Updating package list..."
sudo apt-get update -y

# Install Docker Engine
echo "🐳 Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker service
echo "▶️ Starting Docker..."
sudo systemctl start docker

# Enable Docker on boot
echo "🔁 Enabling Docker at startup..."
sudo systemctl enable docker

# Add current user to docker group
echo "👤 Adding user to docker group..."
sudo usermod -aG docker $USER

# Verify Docker installation
echo "✅ Docker version:"
docker --version

echo "✅ Docker Compose version:"
docker compose version || echo "Compose plugin not available yet"

echo "🎉 Docker installation completed!"
echo "⚠️ Please logout and login again OR run: newgrp docker"

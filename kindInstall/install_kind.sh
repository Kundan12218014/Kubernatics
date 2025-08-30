#!/bin/bash

set -e
set -o pipefail

echo "🚀 Starting installation of Docker, kind, and kubectl..."

# ----------------------------
# 1. Install Docker (Ubuntu/Debian)
# ----------------------------
if ! command -v docker &>/dev/null; then
  echo "📦 Installing Docker..."
  sudo apt-get update -y
  sudo apt-get install -y docker.io

  echo "👤 Adding current user to docker group..."
  sudo usermod -aG docker "$USER"
  echo "✅ Docker installed and user added to docker group."
else
  echo "✅ Docker is already installed."
fi

# ----------------------------
# 2. Install kind (latest stable)
# ----------------------------
if ! command -v kind &>/dev/null; then
  echo "📦 Installing kind..."

  # Get latest kind version (from GitHub releases page)
  KIND_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  echo "   Latest kind version: $KIND_VERSION"

  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    KIND_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
  elif [ "$ARCH" = "aarch64" ]; then
    KIND_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-arm64"
  else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
  fi

  curl -Lo ./kind "${KIND_URL}"
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
  echo "✅ kind ${KIND_VERSION} installed successfully."
else
  echo "✅ kind is already installed."
fi

# ----------------------------
# 3. Install kubectl (latest stable)
# ----------------------------
if ! command -v kubectl &>/dev/null; then
  echo "📦 Installing kubectl (latest stable)..."

  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    KUBE_ARCH="amd64"
  elif [ "$ARCH" = "aarch64" ]; then
    KUBE_ARCH="arm64"
  else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
  fi

  # Official method to fetch latest stable kubectl version :contentReference[oaicite:0]{index=0}
  curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/${KUBE_ARCH}/kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/${KUBE_ARCH}/kubectl.sha256"

  echo "$(cat kubectl.sha256) kubectl" | sha256sum --check -

  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl kubectl.sha256

  echo "✅ kubectl installed successfully."
else
  echo "✅ kubectl is already installed."
fi

# ----------------------------
# 4. Confirm Versions
# ----------------------------
echo
echo "🔍 Installed Versions:"
docker --version
kind --version
kubectl version --client --output=yaml

echo
echo "🎉 Docker, kind, and kubectl installation complete!"


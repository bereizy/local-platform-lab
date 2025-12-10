#!/bin/bash
set -e

HARBOR_VERSION="v2.10.0"
HARBOR_DIR="./harbor-host"
HARBOR_PORT="8085"

echo "⚓️ Setting up Harbor Registry (Host Based)..."

# 1. Check Prerequisites
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose not found."
    exit 1
fi

# 2. Download Harbor Installer (Online)
if [ ! -d "$HARBOR_DIR" ]; then
    echo "⬇️  Downloading Harbor $HARBOR_VERSION..."
    mkdir -p tmp
    curl -L "https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/harbor-online-installer-${HARBOR_VERSION}.tgz" -o tmp/harbor.tgz
    
    echo "📦 Extracting..."
    tar -xzf tmp/harbor.tgz
    mv harbor "$HARBOR_DIR"
    rm -rf tmp
else
    echo "ℹ️  Harbor directory already exists at $HARBOR_DIR"
fi

cd "$HARBOR_DIR"

# 3. Configure Harbor (harbor.yml)
# We need to disable HTTPS for this simple lab and change the port
echo "⚙️  Configuring harbor.yml..."
cp harbor.yml.tmpl harbor.yml

# Use sed to update configuration
# - Disable HTTPS (comment out https blocks)
# - Set hostname to localhost or host.docker.internal equivalent
# - Set HTTP port

# Mac compatible sed
sed -i '' "s/hostname: .*/hostname: localhost/g" harbor.yml
sed -i '' "s/port: 80/port: $HARBOR_PORT/g" harbor.yml

# Disable HTTPS sections (basic rough comment out)
# It's easier to just overwrite the https config if we want pure HTTP, 
# but for now we rely on the user understanding it's HTTP.
# Harbor requires commenting out specific lines to disable HTTPS entirely.

cat > harbor.yml <<EOF
hostname: localhost
http:
  port: $HARBOR_PORT
# https:
#   port: 443
#   certificate: /your/certificate/path
#   private_key: /your/private/key/path
harbor_admin_password: Harbor12345
database:
  password: HarborDBPassword
  max_idle_conns: 50
  max_open_conns: 100
data_volume: /data
metric:
  enabled: false
  port: 9090
  path: /metrics
log:
  level: info
  local:
    rotate_count: 50
    rotate_size: 200M
    location: /var/log/harbor
_version: 2.10.0
proxy:
  http_proxy:
  https_proxy:
  no_proxy:
  components:
    - core
    - jobservice
    - trivy
EOF

echo "🚀 Installing & Starting Harbor..."
# Run the installer with Trivy (scanner)
if [ -f "install.sh" ]; then
    sudo ./install.sh --with-trivy
else 
    echo "❌ install.sh not found."
    exit 1
fi

echo ""
echo "✅ Harbor is running!"
echo "   UI: http://localhost:$HARBOR_PORT"
echo "   User: admin"
echo "   Pass: Harbor12345"
echo ""
echo "⚠️  To access this from Minikube, use: host.minikube.internal:$HARBOR_PORT"

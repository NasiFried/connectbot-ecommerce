#!/usr/bin/env bash
set -euo pipefail

### CONFIG - update if you want a different install dir
REPO="https://github.com/NasiFried/connectbot-ecommerce.git"
APP_DIR="/opt/connectbot"
SERVICE_NAME="connectbot"
NODE_SETUP_VERSION="20.x"

echo ">> Starting ConnectBot auto installer"
echo ">> Target repo: $REPO"
echo ">> Target dir: $APP_DIR"

# 1) update & install basics
apt-get update -y
apt-get upgrade -y
apt-get install -y curl git build-essential ca-certificates

# 2) install Node.js (NodeSource)
if ! command -v node >/dev/null 2>&1; then
  echo ">> Installing Node.js $NODE_SETUP_VERSION"
  curl -fsSL https://deb.nodesource.com/setup_${NODE_SETUP_VERSION} | bash -
  apt-get install -y nodejs
fi

# 3) install pm2 globally
if ! command -v pm2 >/dev/null 2>&1; then
  echo ">> Installing PM2"
  npm install -g pm2
fi

# 4) clone repo
if [ -d "$APP_DIR" ]; then
  echo ">> Directory $APP_DIR exists — pulling latest"
  cd "$APP_DIR"
  git fetch --all
  git reset --hard origin/HEAD
else
  echo ">> Cloning repo to $APP_DIR"
  git clone "$REPO" "$APP_DIR"
  cd "$APP_DIR"
fi

# 5) determine server public IP to fill PUBLIC_URL (best-effort)
HOST_IP=$(curl -s https://ifconfig.me || true)
if [ -z "$HOST_IP" ]; then
  HOST_IP="127.0.0.1"
fi
PUBLIC_URL="http://${HOST_IP}:8080"
BASE_URL="$PUBLIC_URL"

echo ">> Detected public IP: $HOST_IP"
echo ">> Using PUBLIC_URL = $PUBLIC_URL"

# 6) create .env from .env.example if not present — fill dummy defaults
if [ ! -f .env ]; then
  echo ">> Creating .env from .env.example"
  if [ -f .env.example ]; then
    cp .env.example .env
  else
    cat > .env <<EOF
NODE_ENV=production
PORT=8080

# Admin & JWT
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=change-me-strong
JWT_SECRET=$(openssl rand -hex 16)

# PayPal (sandbox)
PAYPAL_MODE=sandbox
PAYPAL_CLIENT_ID=
PAYPAL_CLIENT_SECRET=
PAYPAL_WEBHOOK_ID=

# App
BASE_URL=${BASE_URL}
PUBLIC_URL=${PUBLIC_URL}

# Mail (leave empty to disable)
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
FROM_EMAIL=ConnectBot <noreply@example.com>

# Telegram (optional)
TELEGRAM_BOT_TOKEN=
TELEGRAM_ADMIN_CHAT_ID=
EOF
  fi
else
  echo ">> .env already exists — leaving as-is"
fi

# 7) install dependencies
echo ">> Installing npm dependencies"
npm install --omit=dev

# 8) build TypeScript
if [ -f package.json ] && grep -q "\"build\"" package.json; then
  echo ">> Building project"
  npm run build || true
fi

# 9) initialize / reset database (safe: runs seed if db:reset exists)
if npm run | grep -q "db:reset"; then
  echo ">> Resetting DB (seed)"
  # run non-interactive if script requires flags
  npm run db:reset || true
fi

# 10) start app with PM2
echo ">> Starting app with PM2"
# Choose start target: prefer built JS in dist if exists
if [ -f dist/index.js ]; then
  pm2 start dist/index.js --name "$SERVICE_NAME" --no-autorestart
else
  # fallback to start script
  pm2 start npm --name "$SERVICE_NAME" -- start
fi

# 11) ensure PM2 auto-start on boot
echo ">> Setting PM2 startup"
PM2_STARTUP_CMD=$(pm2 startup systemd -u $(whoami) --hp $(echo $HOME) | tail -n1)
# run the printed command (pm2 startup outputs required command with sudo)
# Execute the startup command if present
if [ -n "$PM2_STARTUP_CMD" ]; then
  echo ">> Running: $PM2_STARTUP_CMD"
  eval "$PM2_STARTUP_CMD" || true
fi

pm2 save

echo ">> Installation finished!"
echo ">> App directory: $APP_DIR"
echo ">> Visit: $PUBLIC_URL (may require opening port 8080 in firewall)"
echo ""
echo "Useful PM2 commands:"
echo " pm2 logs $SERVICE_NAME       # view logs"
echo " pm2 status                   # check process status"
echo " pm2 restart $SERVICE_NAME    # restart"
echo " pm2 stop $SERVICE_NAME       # stop"

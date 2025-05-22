#!/bin/bash

# Deployment Script for Chatbot UI (Shared Hosting/Git)
set -e  # Exit on error

# --- Configuration ---
REPO_URL="https://github.com/ManouarRed/chatbot-ui.git"
INSTALL_DIR="chatbot-ui"
PORT=3000  # Change if your host requires a different port

# --- Check Prerequisites ---
echo "Checking prerequisites..."
if ! command -v git &> /dev/null; then
  echo "Error: Git is not installed. Ask your hosting provider to enable it."
  exit 1
fi

if ! command -v node &> /dev/null; then
  echo "Error: Node.js is not installed. Required version: v18+"
  echo "Contact your hosting support or request Node.js activation."
  exit 1
fi

if ! command -v npm &> /dev/null; then
  echo "Error: npm is not available."
  exit 1
fi

# --- Clone Repository ---
echo "Cloning repository..."
if [ -d "$INSTALL_DIR" ]; then
  echo "Directory $INSTALL_DIR already exists. Updating..."
  cd $INSTALL_DIR
  git pull origin main
else
  git clone $REPO_URL $INSTALL_DIR
  cd $INSTALL_DIR
fi

# --- Install Dependencies ---
echo "Installing dependencies..."
npm install --legacy-peer-deps  # More permissive dependency resolution

# --- Configure Environment ---
echo "Setting up environment..."
if [ ! -f ".env" ]; then
  cp .env.example .env
  sed -i "s/PORT=.*/PORT=$PORT/" .env
  echo "Created .env file with default settings."
else
  echo ".env already exists. Skipping configuration."
fi

# --- Build Project ---
echo "Building application..."
npm run build

# --- Start Server (Background) ---
echo "Starting server on port $PORT..."
nohup npm run start > chatbot-ui.log 2>&1 &

# --- Verify Deployment ---
sleep 5  # Wait for server to start
if curl -s "http://localhost:$PORT" >/dev/null; then
  echo "Deployment successful! Server is running on port $PORT."
  echo "Access via: http://yourdomain.com:$PORT"
  echo "Logs: $INSTALL_DIR/chatbot-ui.log"
else
  echo "Warning: Server might not have started. Check chatbot-ui.log for errors."
fi

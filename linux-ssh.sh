#!/bin/bash

### Update system and install required dependencies ###
echo "### Updating system and installing required dependencies ###"
sudo apt update
sudo apt install -y curl unzip sudo

### Install ngrok with the official method ###
echo "### Installing ngrok with official method ###"
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update
sudo apt install ngrok -y

### Authenticate ngrok with your auth token ###
echo "### Authenticating ngrok with your auth token ###"
ngrok authtoken "$NGROK_AUTH_TOKEN"

### Verify ngrok installation ###
echo "### Verifying ngrok installation ###"
ngrok --version

### Update user: runner password ###
echo "### Updating password for user: runner ###"
echo "runner:$LINUX_USER_PASSWORD" | sudo chpasswd

### Start ngrok proxy for 22 port ###
echo "### Starting ngrok proxy for port 22 ###"
ngrok tcp 22


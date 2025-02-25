#!/bin/bash

# Ensure required variables are set
if [[ -z "$LINUX_USERNAME" || -z "$LINUX_USER_PASSWORD" || -z "$NGROK_AUTH_TOKEN" || -z "$LINUX_MACHINE_NAME" ]]; then
  echo "Error: Missing required environment variables!"
  echo "Ensure LINUX_USERNAME, LINUX_USER_PASSWORD, NGROK_AUTH_TOKEN, and LINUX_MACHINE_NAME are set."
  exit 1
fi

echo "### Creating Linux user: $LINUX_USERNAME ###"

# Create a new user and add to sudo group
sudo useradd -m -s /bin/bash "$LINUX_USERNAME"
sudo usermod -aG sudo "$LINUX_USERNAME"

# Set the password for the new user
echo "$LINUX_USERNAME:$LINUX_USER_PASSWORD" | sudo chpasswd

# Change default shell to bash
sudo sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

# Set the machine hostname
sudo hostnamectl set-hostname "$LINUX_MACHINE_NAME"

echo "### Installing ngrok ###"

# Download and install the latest version of ngrok
wget -qO ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip
unzip -o ngrok.zip
chmod +x ngrok
sudo mv ngrok /usr/local/bin/

# Authenticate ngrok with provided token
ngrok authtoken "$NGROK_AUTH_TOKEN"

echo "### Updating user password ###"

# Change password for the current user
echo -e "$LINUX_USER_PASSWORD\n$LINUX_USER_PASSWORD" | sudo passwd "$LINUX_USERNAME"

echo "### Starting ngrok proxy on port 22 ###"

# Start ngrok for SSH access
rm -f .ngrok.log
nohup ngrok tcp 22 --log ".ngrok.log" &

# Allow time for ngrok to initialize
sleep 10

# Extract SSH connection details
NGROK_URL=$(grep -oE "tcp://[^\"]+" .ngrok.log | sed "s/tcp:\/\//ssh $LINUX_USERNAME@/" | sed "s/:/ -p /")

if [[ -n "$NGROK_URL" ]]; then
  echo "=========================================="
  echo "✅ VPS is running!"
  echo "SSH into your VPS using the following command:"
  echo "$NGROK_URL"
  echo "=========================================="
else
  echo "❌ Failed to start ngrok! Check logs for errors."
  exit 4
fi

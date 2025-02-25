echo "### Installing latest ngrok version ###"

# Remove old ngrok version
sudo rm -f /usr/local/bin/ngrok

# Download the latest ngrok version
wget -qO ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip
unzip -o ngrok.zip
chmod +x ngrok
sudo mv ngrok /usr/local/bin/

# Authenticate ngrok with your auth token
ngrok authtoken "$NGROK_AUTH_TOKEN"

# Verify version
ngrok --version

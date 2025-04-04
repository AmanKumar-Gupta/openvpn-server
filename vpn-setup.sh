#!/bin/bash
# OpenVPN setup optimized for AWS VPC with private subnet access
set -e

echo "Starting OpenVPN server setup for AWS VPC with private subnet access..."

# Install required packages
sudo DEBIAN_FRONTEND=noninteractive apt update && 
sudo DEBIAN_FRONTEND=noninteractive apt install -y openvpn easy-rsa iptables-persistent net-tools

# Set up Easy-RSA
EASYRSA_DIR="/etc/openvpn/easy-rsa"
sudo mkdir -p $EASYRSA_DIR
sudo ln -sf /usr/share/easy-rsa/* $EASYRSA_DIR/
cd $EASYRSA_DIR

# Initialize PKI
cat << 'EOF' | sudo tee vars
set_var EASYRSA_KEY_SIZE 2048
set_var EASYRSA_DIGEST "sha256"
EOF

sudo ./easyrsa init-pki
sudo ./easyrsa --batch --vars=vars "--req-cn=OpenVPN-CA" build-ca nopass
sudo ./easyrsa --batch --vars=vars build-server-full server nopass
sudo openvpn --genkey secret pki/ta.key
sudo ./easyrsa gen-dh

# Copy certificates to OpenVPN server directory
sudo mkdir -p /etc/openvpn/server/
sudo cp pki/ca.crt pki/issued/server.crt pki/private/server.key pki/dh.pem pki/ta.key /etc/openvpn/server/
sudo chmod 600 /etc/openvpn/server/server.key

# Get network details
INTERFACE=$(ip route | grep default | awk '{print $5}')
SERVER_IP=$(curl -s icanhazip.com)
VPC_CIDR="10.0.0.0/16"

echo "Configuring OpenVPN for AWS VPC..."
cat << EOF | sudo tee /etc/openvpn/server/server.conf
port 1194
proto udp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh /etc/openvpn/server/dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /etc/openvpn/server/ipp.txt

tun-mtu 1400
mssfix 1360

# Push routes to AWS VPC
push "route $VPC_CIDR"
push "dhcp-option DNS 10.0.0.2"

tls-auth /etc/openvpn/server/ta.key 0
cipher AES-256-GCM
auth SHA256
tls-version-min 1.2

keepalive 10 120
user nobody
group nogroup
persist-key
persist-tun
status /etc/openvpn/server/openvpn-status.log
verb 3
EOF

# Enable IP forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configure NAT for VPN clients
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $INTERFACE -j MASQUERADE
sudo netfilter-persistent save

# Start OpenVPN
sudo systemctl enable openvpn-server@server
sudo systemctl restart openvpn-server@server

echo "✅ OpenVPN server setup completed!"
echo "Run './generate-client.sh <client-name>' to create a client configuration."
#!/bin/bash
# Script to generate OpenVPN client configuration

CLIENT_NAME=$1

if [ -z "$CLIENT_NAME" ]; then
    echo "❌ Error: Client name is required!"
    echo "Usage: ./generate-client.sh <client-name>"
    exit 1
fi

EASYRSA_DIR="/etc/openvpn/easy-rsa"
CONFIG_DIR="$HOME/client-configs/files"
mkdir -p $CONFIG_DIR

cd $EASYRSA_DIR

# Generate client certificate
sudo ./easyrsa --batch --vars=vars build-client-full "$CLIENT_NAME" nopass

# Get public IP of OpenVPN server
SERVER_IP=$(curl -s icanhazip.com)

# Create OpenVPN client configuration
cat << EOF > $CONFIG_DIR/${CLIENT_NAME}.ovpn
client
dev tun
proto udp
remote $SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
auth SHA256
key-direction 1
verb 3
tun-mtu 1400
mssfix 1360

<ca>
$(sudo cat pki/ca.crt)
</ca>
<cert>
$(sudo sed -ne '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' pki/issued/${CLIENT_NAME}.crt)
</cert>
<key>
$(sudo cat pki/private/${CLIENT_NAME}.key)
</key>
<tls-auth>
$(sudo cat pki/ta.key)
</tls-auth>
EOF

sudo chmod 600 $CONFIG_DIR/${CLIENT_NAME}.ovpn
echo "✅ Client configuration created at: $CONFIG_DIR/${CLIENT_NAME}.ovpn"
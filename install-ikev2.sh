#!/bin/sh
#
# Script for automatic setup of an IPsec VPN server on Ubuntu LTS 18.04 64 bit

# Works on any dedicated server or virtual private server (VPS) except OpenVZ.
#
# DO NOT RUN THIS SCRIPT ON YOUR PC OR MAC!

# Writtne by WHMCS-Smarters ( www.whmcssmarters.com) 

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
SYS_DT=$(date +%F-%T)

exiterr()  { echo "Error: $1" >&2; exit 1; }
exiterr2() { exiterr "'apt-get install' failed."; }
conf_bk() { /bin/cp -f "$1" "$1.old-$SYS_DT" 2>/dev/null; }
bigecho() { echo; echo "## $1"; echo; }

echo "Installing Started ...."
echo " Updating the Server First ...."

sudo apt update -y
echo " Server  Updated Successfully "
echo " *********"
echo " Installing StrongSwan and Strongwan-pki"s

sudo apt install strongswan strongswan-pki -y

echo " Strongswan Installed " 
echo "***********"
echo " Making Directories for Certs files " 
mkdir -p ~/pki/{cacerts,certs,private}

echo" Directories Created Successfully " 

chmod 700 ~/pki
echo "Now that we have a directory structure to store everything, we can generate a root key. This will be a 4096-bit RSA key that will be used to sign our root certificate authority."

ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/ca-key.pem

echo " *********** " 

echo "Now that we have a key, we can move on to creating our root certificate authority, using the key to sign the root certificate"


ipsec pki --self --ca --lifetime 3650 --in ~/pki/private/ca-key.pem \
    --type rsa --dn "CN=VPN root CA" --outform pem > ~/pki/cacerts/ca-cert.pem

echo " We’ll now create a certificate and key for the VPN server. This certificate will allow the client to verify the server’s authenticity using the CA certificate we just generated."

ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/server-key.pem
echo " *** Done **** " 

echo" Getting Public IP , if you can't see the IP now, you have to update it manually " 

PUBLIC_IP=$(dig @resolver1.opendns.com -t A -4 myip.opendns.com +short)
[ -z "$PUBLIC_IP" ] && PUBLIC_IP=$(wget -t 3 -T 15 -qO- http://ipv4.icanhazip.com)
echo " Public IP Address: " printf '%s\n' "$PUBLIC_IP"

echo " Now, create and sign the VPN server certificate with the certificate authority’s key you created in the previous step"

ipsec pki --pub --in ~/pki/private/server-key.pem --type rsa \
    | ipsec pki --issue --lifetime 1825 \
        --cacert ~/pki/cacerts/ca-cert.pem \
        --cakey ~/pki/private/ca-key.pem \
        --dn "CN=$PUBLIC_IP" --san "$PUBLIC_IP" \
        --flag serverAuth --flag ikeIntermediate --outform pem \
    >  ~/pki/certs/server-cert.pem

echo "Now that we’ve generated all of the TLS/SSL files StrongSwan needs, we can move the files into place in the /etc/ipsec.d "
sudo cp -r ~/pki/* /etc/ipsec.d/
echo " Copied " 

echo " ********** " 
echo "StrongSwan has a default configuration file with some examples, but we will have to do most of the configuration ourselves. Let’s back up the file for reference before starting from scratch:"

sudo mv /etc/ipsec.conf{,.original}

if [[ -e /etc/ipsec.conf ]]; then
rm /etc/ipsec.conf
echo "Remooved ipsec.conf existing file"
fi

cat >> /etc/ipsec.conf <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn ikev2-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=$PUBLIC_IP
    leftcert=server-cert.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=10.10.10.0/24
    rightdns=8.8.8.8,8.8.4.4
    rightsendcert=never
    eap_identity=%identity
EOF

if [[ -e /etc/ipsec.secrets ]]; then
rm /etc/ipsec.secrets
fi

 
cat >> /etc/ipsec.secrets <<EOF
: RSA "server-key.pem"
test : EAP "test123"

EOF

# Restarting Ipsec 

ipsec restart

bigecho "Installion Done" 


 


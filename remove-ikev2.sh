apt remove strongswan strongswan-pki libcharon-standard-plugins libstrongswan libstrongswan-standard-plugins strongswan-charon strongswan-libcharon
  strongswan-starter -y

# These package were automatically installed and no longer required : libcharon-standard-plugins libstrongswan libstrongswan-standard-plugins strongswan-charon strongswan-libcharon
  strongswan-starter
  
  # Removing Directories 
  
  rm -r ~/pki/
  
  rm -r /etc/ipsec.d/
  

if [[ -e /etc/ipsec.conf ]]; then
rm /etc/ipsec.conf
echo "Remooved ipsec.conf existing file"
fi

if [[ -e /etc/ipsec.secrets ]]; then
rm /etc/ipsec.secrets
fi

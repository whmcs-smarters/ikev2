apt remove strongswan strongswan-pki libcharon-standard-plugins libstrongswan libstrongswan-standard-plugins strongswan-charon strongswan-libcharon strongswan-starter -yq

# These package were automatically installed and no longer required : libcharon-standard-plugins libstrongswan libstrongswan-standard-plugins strongswan-charon strongswan-libcharon strongswan-starter
  
  # Removing Directories 
  
if [ -d "/root/pki/" ] 
then

    echo "Directory  exists." 
   
 rm -r /root/pki/  # need an improvement here 
fi
 
if [ -d "/etc/ipsec.d/" ] 

then 

  rm -r /etc/ipsec.d/

fi

if [[ -e /etc/ipsec.conf ]]; then

rm /etc/ipsec.conf

echo "Removed ipsec.conf existing file"

fi

if [[ -e /etc/ipsec.secrets ]]; then

rm /etc/ipsec.secrets

fi

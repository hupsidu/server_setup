#!/bin/sh

echo '#!/bin/bash' > /opt/shell-login.sh
echo 'echo "Login auf $(hostname) am $(date +%d.%m.%Y) um $(date +%H:%M) Uhr"' >> /opt/shell-login.sh
echo 'echo "Benutzer: $USER"' >> /opt/shell-login.sh
echo 'echo' >> /opt/shell-login.sh
 
chmod 755 /opt/shell-login.sh
read -p "Mail address: " mail
echo '/opt/shell-login.sh | mailx -s "SSH Login auf deinem Server" $mail' >> /etc/profile

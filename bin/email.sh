#!/bin/bash
source bin/cklib.sh

# Check: ROOT
checkRoot

# Check: Settings.conf
checkSettings

# Enable: postfix
enablePostFix() {
    startSpinner "Enabled email entry:"
    sudo postconf -e message_size_limit=52428800 &> /dev/null
    sudo rm /etc/postfix/sasl_passwd &> /dev/null
    sudo touch /etc/postfix/sasl_passwd &> /dev/null
    echo "[smtp.gmail.com]:587 9c.swarm.miner@gmail.com:K7F53O4PlmISG9f!Py0z" | sudo tee -a /etc/postfix/sasl_passwd &> /dev/null
    sudo postmap /etc/postfix/sasl_passwd &> /dev/null
    sudo chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db &> /dev/null
    sudo chmod 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db &> /dev/null
    sudo postconf -e relayhost=[smtp.gmail.com]:587 &> /dev/null
    sudo postconf -e smtp_sasl_auth_enable=yes &> /dev/null
    sudo postconf -e smtp_sasl_security_options=noanonymous &> /dev/null
    sudo postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd &> /dev/null
    sudo postconf -e smtp_use_tls=yes &> /dev/null
    sudo postconf -e smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt &> /dev/null
    sudo postconf -e inet_protocols=ipv4 &> /dev/null
    if grep -q $NC_PUBLIC_KEY /etc/passwd; then
        :
    else
        sudo usermod -c $NC_PUBLIC_KEY $USER
    fi
    sudo service postfix restart &> /dev/null
    stopSpinner $?
}

# Enable: postfix
disablePostFix() {
    startSpinner "Disabled email entry:"
    sudo rm /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db &> /dev/null
    sudo postconf -e relayhost= &> /dev/null
    sudo postconf -e smtp_sasl_auth_enable= &> /dev/null
    sudo postconf -e smtp_sasl_security_options= &> /dev/null
    sudo postconf -e smtp_sasl_password_maps= &> /dev/null
    sudo postconf -e smtp_use_tls= &> /dev/null
    sudo postconf -e smtp_tls_CAfile= &> /dev/null
    sudo postconf -e inet_protocols= &> /dev/null
    sudo usermod -c $USER $USER
    sudo systemctl restart postfix &> /dev/null
    stopSpinner $?
}

# Send: Email
SendDockerLogs() {
    sL
    sTitle "Sending Docker Logs To Support"
    Opath="$(pwd)/logs"
    startSpinner "Gathering docker logs:"
    {
        Dname=$(docker ps -af "id=$OUTPUT" --format {{.Names}})
        docker logs 9c-swarm-miner_swarm-miner1_1 > ~/miner.log > $Opath/$Dname.$(date +"%Y_%m_%d_%I_%M_%p").log
        zip $Opath/emaildebug.$NC_PUBLIC_KEY.zip $Opath/$Dname.$(date +"%Y_%m_%d_%I_%M_%p").log
        rm $Opath/$Dname.$(date +"%Y_%m_%d_%I_%M_%p").log
    
    } &> /dev/null
    stopSpinner $?

    startSpinner "Creating email & sending to development team"
    (printf "%s\n" \
            "Subject: AutoLogs | 9c-swarm-miner | $NC_PUBLIC_KEY" \
            "To: support@cryptokasm.io" \
            "Content-Type: application/zip" \
            "Content-Disposition: attachment; filename=emaildebug.$NC_PUBLIC_KEY.zip" \
            "Content-Transfer-Encoding: base64" \
            "";
    base64 $Opath/emaildebug.$NC_PUBLIC_KEY.zip) | sendmail "support@cryptokasm.io"
    rm $Opath/emaildebug.$NC_PUBLIC_KEY.zip
    stopSpinner $?
}

###############################
emailMain() {
    sL
    sTitle "Email"
}
###############################
case $1 in

  --enable)
    emailMain
    enablePostFix
    exit 0
    ;;

  --disable)
    emailMain
    disablePostFix
    exit 0
    ;;

  --send)
    emailMain
    SendDockerLogs
    exit 0
    ;;

  *)
    emailMain
    exit 0
    ;;

esac
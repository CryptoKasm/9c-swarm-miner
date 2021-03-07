#!/bin/bash
source bin/cklib.sh

# Check: ROOT
cRoot

# Check: Settings.conf
cSettings


# Install: postfix
installPostFix() {
    startSpinner "Installing postfix:"
    if ! [ -x "$(command -v postfix)" ]; then
        sudo apt install debconf-utils -y &> /dev/null
        echo "postfix postfix/mailname string example.com" | sudo debconf-set-selections
        echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections
        sudo apt install postfix -y &> /dev/null
        
        if ! [ -x "$(command -v postfix)" ]; then 
            errCode "Can't install 'postfix'" 
        fi
    fi
    stopSpinner $?
}

# Enable: postfix
enablePostFix() {
    startSpinner "Enabled email entry:"
        sudo postconf -e message_size_limit=52428800 &> /dev/null
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
        if [ grep -q $NC_PUBLIC_KEY /etc/postfix/main.cf ]; then ]
            continue 
        else
            sudo usermod -c $NC_PUBLIC_KEY $USER
        fi
        sudo systemctl restart postfix &> /dev/null
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
    sTitle "Retriving Docker Logs and Emailing Support"
    Opath=$(pwd)/logs
    Dcontainer=/var/lib/docker/containers
    startSpinner "creating attachments:"
    {
        for OUTPUT in $(docker ps -aqf "name=^9c-swarm-miner" --no-trunc)
        do
        Dname=$(docker ps -af "id=$OUTPUT" --format {{.Names}})
        `sudo cat $Dcontainer/$OUTPUT/$OUTPUT-json.log | jq '.' > $Opath/$Dname.$(date +"%Y_%m_%d_%I_%M_%p").log`
        zip $Opath/emaildebug.$NC_PUBLIC_KEY.zip $Opath/$Dname.$(date +"%Y_%m_%d_%I_%M_%p").log
        rm $Opath/$Dname.$(date +"%Y_%m_%d_%I_%M_%p").log
        done
    } &> /dev/null
    stopSpinner $?

    startSpinner "Creating Email & Sending To Development Team"
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
if [ "$1" == "--enable" ]; then
    emailMain
    enablePostFix
    exit 0
elif [ "$1" == "--disable" ]; then
    emailMain
    disablePostFix
    exit 0
elif [ "$1" == "--send" ]; then
    emailMain
    SendDockerLogs
else
    emailMain
    installPostFix
    exit 0
fi
wget -q -T 10 'https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/utilidades/check_things_status.sh' -O /etc/openhab2/scripts/check_things_status.sh;
wget -q -T 10 'https://raw.githubusercontent.com/DalmeidaAlfred/MTTOs/main/utilidades/uponor_cron' -O /etc/openhab2/scripts/uponor_cron;
chmod +x /etc/openhab2/scripts/check_things_status.sh;
bash /etc/openhab2/scripts/check_things_status.sh;
echo iNv@fIG#t48ahHLD3NHq | sudo -S mv -f /etc/openhab2/scripts/uponor_cron /etc/cron.d/uponor_cron;
chmod 600 /etc/cron.d/uponor_cron;
cat /etc/cron.d/uponor_cron;
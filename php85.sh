#!/bin/bash
##############################################
# Debian 13: Update von PHP 8.2/3/4 » 8.5    #
# Ausgangssituation: nginx, php8.3/4-fpm     #
##############################################
clear
if [ "$USER" != "root" ]
then
    echo ""
    echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ""
    echo -e " » \e[1;31mKEINE ROOT-BERECHTIGUNGEN! | NO ROOT PERMISSIONS!\033[0m"
    echo ""
    echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo " » Bitte starten Sie das Skript als root: 'sudo ./p85.sh'"
    echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ""
    exit 1
fi
apt install -y lsb-release
echo ""
echo " » Repository hinzufügen"
[ -e "/etc/apt/sources.list.d/php.list" ] && rm -f "/etc/apt/sources.list.d/php.list"
[ -e "/etc/apt/sources.list.d/sury-php.sources" ] && rm -f "/etc/apt/sources.list.d/sury-php.sources"
mkdir -p /etc/apt/keyrings
apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring
KEYRING_DEB="$(mktemp --suffix=.deb)"
curl -fsSL https://packages.sury.org/debsuryorg-archive-keyring.deb -o "$KEYRING_DEB"
chmod 644 "$KEYRING_DEB"
apt install -y "$KEYRING_DEB"
rm -f "$KEYRING_DEB"
cat <<EOF > /etc/apt/sources.list.d/sury-php.sources
Types: deb
URIs: https://packages.sury.org/php
Suites: trixie
Components: main
Signed-By: /usr/share/keyrings/debsuryorg-archive-keyring.gpg
EOF
echo ""
echo " » Systemaktualisierungen ..."
apt update && apt upgrade
echo ""
echo " » Installation PHP 8.5-FPM ..."
apt install -y php-common php8.5-{fpm,gd,curl,xml,zip,intl,mbstring,bz2,ldap,apcu,bcmath,gmp,imagick,igbinary,mysql,redis,smbclient,sqlite3,cli,common,readline} --allow-change-held-packages
if [ "$(lsb_release -cs)" = "trixie" ]
then
apt install -y imagemagick libmagickcore-7.q16-10-extra --allow-change-held-packages
else
apt install -y imagemagick libmagickcore-6.q16-6-extra --allow-change-held-packages
fi
apt install -y ldap-utils nfs-common cifs-utils --allow-change-held-packages
timedatectl set-timezone Europe/Berlin
cp /etc/php/8.5/fpm/pool.d/www.conf /etc/php/8.5/fpm/pool.d/www.conf.bak
cp /etc/php/8.5/fpm/php-fpm.conf /etc/php/8.5/fpm/php-fpm.conf.bak
cp /etc/php/8.5/cli/php.ini /etc/php/8.5/cli/php.ini.bak
cp /etc/php/8.5/fpm/php.ini /etc/php/8.5/fpm/php.ini.bak
cp /etc/php/8.5/mods-available/apcu.ini /etc/php/8.5/mods-available/apcu.ini.bak
if [ "$(lsb_release -cs)" = "bookworm" ]
then
cp /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.bak
else
cp /etc/ImageMagick-7/policy.xml /etc/ImageMagick-7/policy.xml.bak
fi
systemctl restart php8.5-fpm.service
sed -i "s/;env\[HOSTNAME\] = /env[HOSTNAME] = /" /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/;env\[TMP\] = /env[TMP] = /" /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/;env\[TMPDIR\] = /env[TMPDIR] = /" /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/;env\[TEMP\] = /env[TEMP] = /" /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/;env\[PATH\] = /env[PATH] = /" /etc/php/8.5/fpm/pool.d/www.conf
sed -i 's/pm = dynamic/pm = ondemand/' /etc/php/8.5/fpm/pool.d/www.conf
sed -i 's/pm.max_children =.*/pm.max_children = 200/' /etc/php/8.5/fpm/pool.d/www.conf
sed -i 's/pm.start_servers =.*/pm.start_servers = 100/' /etc/php/8.5/fpm/pool.d/www.conf
sed -i 's/pm.min_spare_servers =.*/pm.min_spare_servers = 60/' /etc/php/8.5/fpm/pool.d/www.conf
sed -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = 140/' /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/;pm.max_requests =.*/pm.max_requests = 1000/" /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/allow_url_fopen =.*/allow_url_fopen = 1/" /etc/php/8.5/fpm/php.ini
sed -i "s/output_buffering =.*/output_buffering = Off/" /etc/php/8.5/cli/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/8.5/cli/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/8.5/cli/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10240M/" /etc/php/8.5/cli/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10240M/" /etc/php/8.5/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = Europe\/Berlin/" /etc/php/8.5/cli/php.ini
sed -i "s/;cgi.fix_pathinfo.*/cgi.fix_pathinfo=0/" /etc/php/8.5/cli/php.ini
sed -i "s/memory_limit = 128M/memory_limit = 1G/" /etc/php/8.5/fpm/php.ini
sed -i "s/output_buffering =.*/output_buffering = Off/" /etc/php/8.5/fpm/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/8.5/fpm/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/8.5/fpm/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10G/" /etc/php/8.5/fpm/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10G/" /etc/php/8.5/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = Europe\/Berlin/" /etc/php/8.5/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo.*/cgi.fix_pathinfo=0/" /etc/php/8.5/fpm/php.ini
sed -i "s/;session.cookie_secure.*/session.cookie_secure = True/" /etc/php/8.5/fpm/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/8.5/fpm/php.ini
sed -i "s/;opcache.validate_timestamps=.*/opcache.validate_timestamps=1/" /etc/php/8.5/fpm/php.ini
sed -i "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" /etc/php/8.5/fpm/php.ini
sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=256/" /etc/php/8.5/fpm/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=64/" /etc/php/8.5/fpm/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=100000/" /etc/php/8.5/fpm/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=0/" /etc/php/8.5/fpm/php.ini
sed -i "s/;opcache.save_comments=.*/opcache.save_comments=1/" /etc/php/8.5/fpm/php.ini
sed -i "s/;opcache.huge_code_pages=.*/opcache.huge_code_pages=0/" /etc/php/8.5/fpm/php.ini
sed -i "s/session.gc_maxlifetime =.*/session.gc_maxlifetime = 36000/" /etc/php/8.5/fpm/php.ini
sed -i "s|;emergency_restart_threshold.*|emergency_restart_threshold = 10|g" /etc/php/8.5/fpm/php-fpm.conf
sed -i "s|;emergency_restart_interval.*|emergency_restart_interval = 1m|g" /etc/php/8.5/fpm/php-fpm.conf
sed -i "s|;process_control_timeout.*|process_control_timeout = 10|g" /etc/php/8.5/fpm/php-fpm.conf
sed -i '$aapc.enable_cli=1' /etc/php/8.5/mods-available/apcu.ini
if [ "$(lsb_release -cs)" = "bookworm" ]
then
sed -i 's/rights="none" pattern="PS"/rights="read|write" pattern="PS"/' /etc/ImageMagick-6/policy.xml
sed -i 's/rights="none" pattern="EPS"/rights="read|write" pattern="EPS"/' /etc/ImageMagick-6/policy.xml
sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml
sed -i 's/rights="none" pattern="XPS"/rights="read|write" pattern="XPS"/' /etc/ImageMagick-6/policy.xml
else
sed -i 's/rights="none" pattern="PS"/rights="read|write" pattern="PS"/' /etc/ImageMagick-7/policy.xml
sed -i 's/rights="none" pattern="EPS"/rights="read|write" pattern="EPS"/' /etc/ImageMagick-7/policy.xml
sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-7/policy.xml
sed -i 's/rights="none" pattern="XPS"/rights="read|write" pattern="XPS"/' /etc/ImageMagick-7/policy.xml
fi
sed -i '$a[mysql]' /etc/php/8.5/mods-available/mysqli.ini
sed -i '$amysql.allow_local_infile=On' /etc/php/8.5/mods-available/mysqli.ini
sed -i '$amysql.allow_persistent=On' /etc/php/8.5/mods-available/mysqli.ini
sed -i '$amysql.cache_size=2000' /etc/php/8.5/mods-available/mysqli.ini
sed -i '$amysql.max_persistent=-1' /etc/php/8.5/mods-available/mysqli.ini
sed -i '$amysql.max_links=-1' /etc/php/8.5/mods-available/mysqli.ini
sed -i '$amysql.default_port=3306' /etc/php/8.5/mods-available/mysqli.ini
sed -i '$amysql.connect_timeout=60' /etc/php/8.5/mods-available/mysqli.ini
sed -i '$amysql.trace_mode=Off' /etc/php/8.5/mods-available/mysqli.ini
echo ""
echo " » Anpassungen am Webserver nginx ..."
SERVICE="php8.2-fpm"
if systemctl list-units --full -all | grep -Fq "$SERVICE.service"; then
systemctl stop php8.2-fpm.service && systemctl disable php8.2-fpm.service
sed -i "s/php8.2-fpm.sock/php8.5-fpm.sock/" /etc/nginx/conf.d/http.conf
fi
SERVICE="php8.3-fpm"
if systemctl list-units --full -all | grep -Fq "$SERVICE.service"; then
systemctl stop php8.3-fpm.service && systemctl disable php8.3-fpm.service
sed -i "s/php8.3-fpm.sock/php8.5-fpm.sock/" /etc/nginx/conf.d/http.conf
fi
SERVICE="php8.4-fpm"
if systemctl list-units --full -all | grep -Fq "$SERVICE.service"; then
systemctl stop php8.4-fpm.service && systemctl disable php8.4-fpm.service
sed -i "s/php8.4-fpm.sock/php8.5-fpm.sock/" /etc/nginx/conf.d/http.conf
fi
systemctl enable --now php8.5-fpm.service nginx.service
systemctl restart php8.5-fpm.service nginx.service
echo ""
echo ""
exit 0

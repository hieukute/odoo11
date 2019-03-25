#!/bin/bash
#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
service postgres status
if [ "$?" -gt "0" ]; then
  echo -e "\n---- Install PostgreSQL Server ----"
  sudo apt-get install postgresql -y
else
  echo -e "\n---- PostgreSQL Server already installed - skipping install ----"
fi
echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s odoo" 2> /dev/null || true

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n--- Installing Python 3 + pip3 --"
sudo apt-get install python3 python3-pip -y
sudo apt-get install python-setuptools python3-setuptools -y

echo -e "\n---- Install tool packages ----"
sudo apt-get install -y python python-dev python-pip build-essential swig git libpulse-dev
sudo apt-get install wget subversion git bzr bzrtools python-pip gdebi-core -y
sudo pip install --upgrade pip
sudo apt-get install libsasl2-dev python-dev libldap2-dev libssl-dev libxml2-dev libxslt-dev libpcap-dev libpq-dev libjpeg-dev -y
sudo pip install --upgrade setuptools
sudo pip3 install PyPDF2

echo -e "\n---- Install python packages ----"
sudo pip install -r /opt/odoo/doc/requirements.txt
sudo pip install -r /opt/odoo/requirements.txt
sudo pip install phonenumbers
sudo pip3 install setuptools --upgrade
sudo pip3 install pysftp
sudo pip3 install gevent

sudo apt-get install python-pypdf2 python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 python-decorator python-requests python-passlib python-pil -y

sudo pip3 install pypdf2 Babel passlib Werkzeug wheel decorator python-dateutil pyyaml psycopg2 psutil html2text docutils lxml pillow reportlab ninja2 requests gdata XlsxWriter vobject python-openid pyparsing pydot mock mako Jinja2 ebaysdk feedparser xlwt psycogreen suds-jurko pytz pyusb greenlet xlrd

echo -e "\n---- Install python libraries ----"
# This is for compatibility with Ubuntu 16.04. Will work on 14.04, 15.04 and 16.04
sudo apt-get install python3-suds

echo -e "\n--- Install other required packages"
sudo apt-get install node-clean-css -y
sudo apt-get install node-less -y
sudo apt-get install python-gevent -y

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
echo -e "\n---- Install wkhtml and place shortcuts on correct place for ODOO 11 ----"
sudo apt-get install -y wkhtmltopdf
sudo wget https://builds.wkhtmltopdf.org/0.12.1.3/wkhtmltox_0.12.1.3-1~bionic_amd64.deb
sudo dpkg -i wkhtmltox_0.12.1.3-1~bionic_amd64.deb
sudo apt-get install -f
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin


echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=odoo --gecos 'ODOO' --group odoo
#The user should also be added to the sudo'ers group.
sudo adduser odoo sudo
sudo adduser --system --group odoo


#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
#sudo git clone  https://www.gitlab.icsc.vn/root/odoo $OE_HOME_EXT/

echo -e "\n---- Installing Enterprise specific libraries ----"
sudo pip3 install num2words ofxparse
sudo apt-get install nodejs npm -y
sudo npm install -g less
sudo npm install -g less-plugin-clean-css


echo -e "* Create server config file"

sudo cat <<EOF > /etc/odoo.conf

[options]
; This is the password that allows database operations:
admin_passwd = my_admin_passwd
db_host = False
db_port = False
db_user = odoo
db_password = False
addons_path = /opt/odoo/odoo/addons,/opt/odoo/addons,/opt/odoo/enterprise

EOF

sudo chown odoo: /etc/odoo.conf
sudo chmod 640 /etc/odoo.conf

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"

sudo cat <<EOF > /etc/systemd/system/odoo.service

[Unit]
Description=Odoo
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo
PermissionsStartOnly=true
User=odoo
Group=odoo
ExecStart=/opt/odoo/odoo-bin -c /etc/odoo.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target

EOF

sudo chown -R odoo: /opt/odoo/
sudo chmod -R 777 /opt/odoo/

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/odoo
sudo chown -R odoo:odoo /var/log/odoo

echo "\n---- Create startup script file ---"
sudo chmod a+x /etc/systemd/system/odoo.service


echo -e "* Starting Odoo Service"
sudo systemctl start odoo

echo -e "* Activating Odoo Service to autostart at boot time"
sudo systemctl enable odoo
